# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

## +-------
## | CODEBUILD - Plan & Validation
## +---------------------------------

resource "aws_codebuild_project" "validation" {
  name         = "${var.project_name}-validation"
  description  = "Validates repository files"
  service_role = aws_iam_role.codebuild_role_plan.arn
  tags         = var.tags

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    environment_variable {
      name  = "SECURITY_GATE"
      value = jsonencode(var.security_gate)
    }
    environment_variable {
      name  = "INFERENCE_PROFILE"
      value = jsonencode(var.bedrock_model_id)
    }    
  }



  logs_config {
    cloudwatch_logs {
      group_name = "${var.project_name}-validation"
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = jsonencode({
      version = "0.2"
      phases = {
        install = {
          commands = [
            "echo  '[INFO] [INSTALL] Installing dependencies'",
            "wget https://releases.hashicorp.com/terraform/${local.terraform_version}/terraform_${local.terraform_version}_linux_amd64.zip",
            "unzip terraform_*_linux_amd64.zip -d /usr/bin/",
            "chmod +x /usr/bin/terraform",
            "mkdir source",
            "cd source",
            "aws s3api get-object --bucket ${aws_s3_bucket.artifacts.id} --key scripts/source.zip source.zip",
            "unzip source.zip -d .",
            "rm source.zip",
            "echo '[INFO] [INSTALL] Installing finished'"
          ]
        }
        build = {
          commands = var.enable_bedrock ? [
            "echo '[INFO] Starting build phase'",
            "cd terraform/",
            "chmod +x ../scp-policy-processor/main.py",
            "python3 ../scp-policy-processor/main.py",
            "chmod +x ../rcp-policy-processor/main.py",
            "python3 ../rcp-policy-processor/main.py",
            "terraform init -backend-config='bucket=${aws_s3_bucket.tfstate.id}' -backend-config='key=${var.project_name}.tfstate' -backend-config='region=${data.aws_region.current.region}'",
            "terraform plan | tee tf.log",
            "python3 ../bedrock-prompt/prompt.py",
            "SUMMARY=$(cat summary.txt)",
            "export SUMMARY"
            ] : [
            "echo '[INFO] Starting build phase'",
            "cd terraform/",
            "chmod +x ../scp-policy-processor/main.py",
            "python3 ../scp-policy-processor/main.py",
            "chmod +x ../rcp-policy-processor/main.py",
            "python3 ../rcp-policy-processor/main.py",
            "terraform init -backend-config='bucket=${aws_s3_bucket.tfstate.id}' -backend-config='key=${var.project_name}.tfstate' -backend-config='region=${data.aws_region.current.region}'",
            "terraform plan | tee tf.log",
            "SUMMARY=$(echo 'You have new SCP/RCP changes to approve. See ValidationPlan logs for more details.')",
            "export SUMMARY"
          ]
        }
      }
      artifacts = {
        name = "org-policies-artifacts"
        files = [
          "**/*"
        ]
      }
      env = {
        exported-variables = [
          "SUMMARY"
        ]
      }
    })
  }

  encryption_key = aws_kms_key.pipeline_key.arn
}

## +-------
## | CODEBUILD - Apply
## +---------------------------------

resource "aws_codebuild_project" "apply" {
  name         = "${var.project_name}-apply"
  description  = "Applies policy changes"
  service_role = aws_iam_role.codebuild_role_apply.arn
  tags         = var.tags

  artifacts {
    type = "CODEPIPELINE"
  }

  logs_config {
    cloudwatch_logs {
      group_name = "${var.project_name}-apply"
    }
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type = "CODEPIPELINE"
    buildspec = jsonencode({
      version = "0.2"
      phases = {
        install = {
          commands = [
            "echo  '[INFO] [INSTALL] Installing dependencies'",
            "wget https://releases.hashicorp.com/terraform/${local.terraform_version}/terraform_${local.terraform_version}_linux_amd64.zip",
            "unzip terraform_*_linux_amd64.zip -d /usr/bin/",
            "chmod +x /usr/bin/terraform",
            "echo '[INFO] [INSTALL] Installing finished'"
          ]
        }
        build = {
          commands = [
            "echo '[INFO] Starting build phase'",
            "cd source/terraform",
            "terraform init -backend-config='bucket=${aws_s3_bucket.tfstate.id}' -backend-config='key=${var.project_name}.tfstate' -backend-config='region=${data.aws_region.current.region}'",
            "terraform apply -auto-approve"
          ]
        }
      }
      artifacts = {
        files = [
          "**/*"
        ]
      }
    })
  }

  encryption_key = aws_kms_key.pipeline_key.arn
}