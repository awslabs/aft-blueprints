# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

## +-------
## | CODESTAR - Connection for source repository
## +---------------------------------

resource "aws_codestarconnections_connection" "connection" {
  name          = "${var.project_name}-connection"
  provider_type = var.provider_type
  tags          = var.tags
}


## +-------
## | CODEPIPELINE - CodePipeline for pipeline's execution
## +---------------------------------

resource "aws_codepipeline" "pipeline" {
  name          = "${var.project_name}-pipeline"
  role_arn      = aws_iam_role.codepipeline_role.arn
  pipeline_type = "V2"
  tags          = var.tags

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"

    encryption_key {
      id   = aws_kms_key.pipeline_key.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.connection.arn
        FullRepositoryId = var.full_repository_name
        BranchName       = var.branch_name
      }
    }
  }

  stage {
    name = "Validation-Plan"

    action {
      name             = "Validate"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      namespace        = "Summary"
      input_artifacts  = ["source_output"]
      output_artifacts = ["plan_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.validation.name
      }
    }
  }

  stage {
    name = "Approval"

    action {
      name     = "Approve"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
      configuration = {
        NotificationArn = "${aws_sns_topic.approval_notification.arn}"
        CustomData      = "#{Summary.SUMMARY}"
      }
    }

  }

  stage {
    name = "Apply"

    action {
      name             = "ApplyPolicy"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["plan_output"]
      output_artifacts = ["apply_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.apply.name
      }
    }
  }
}