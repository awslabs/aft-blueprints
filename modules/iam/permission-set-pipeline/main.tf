# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

# CodeStar connection for github
resource "aws_codestarconnections_connection" "github" {
  count         = local.vcs.is_github ? 1 : 0
  name          = "${var.solution_name}-github"
  provider_type = "GitHub"
}

# CodeStar connection for github enterprise
resource "aws_codestarconnections_connection" "githubenterprise" {
  count    = local.vcs.is_github_enterprise ? 1 : 0
  name     = "${var.solution_name}-github-ent"
  host_arn = aws_codestarconnections_host.githubenterprise[0].arn
}

# CodeStar connection host for github enterprise
resource "aws_codestarconnections_host" "githubenterprise" {
  count             = local.vcs.is_github_enterprise ? 1 : 0
  name              = "permission-set-github-ent-host"
  provider_endpoint = var.github_enterprise_url
  provider_type     = "GitHubEnterpriseServer"

  dynamic "vpc_configuration" {
    for_each = var.enable_vpc_config ? [true] : []
    content {
      security_group_ids = var.vpc_config.security_groups
      subnet_ids         = var.vpc_config.subnets
      vpc_id             = var.vpc_config.vpc_id
    }
  }
}

resource "aws_codecommit_repository" "pipeline" {
  count = local.vcs.is_codecommit ? 1 : 0

  repository_name = var.repository_name
  description     = "Permission Set Pipeline respository"
  default_branch  = var.branch_name
  kms_key_id      = aws_kms_key.cmk.arn
  tags            = var.tags
}

#-------------------------------------------------------------

resource "aws_codebuild_project" "main" {
  name           = "${var.solution_name}-build"
  service_role   = aws_iam_role.codebuild.arn
  encryption_key = aws_kms_alias.cmk_alias.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type         = "LINUX_CONTAINER"
    environment_variable {
      name  = "TF_DDB_TABLE"
      value = aws_dynamodb_table.tf_backend.name
    }
    environment_variable {
      name  = "TF_BUCKET"
      value = aws_s3_bucket.tf_backend.id
    }
    environment_variable {
      name  = "KMS_KEY_ID"
      value = aws_kms_key.cmk.key_id
    }
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = data.local_file.buildspec.content
  }
  logs_config {
    cloudwatch_logs {
      group_name = "/aws/codebuild/${var.solution_name}-build"
    }
  }
  dynamic "vpc_config" {
    for_each = var.enable_vpc_config ? [true] : []
    content {
      security_group_ids = var.vpc_config.security_groups
      subnets            = var.vpc_config.subnets
      vpc_id             = var.vpc_config.vpc_id
    }
  }
  tags = var.tags
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/codebuild/${var.solution_name}-build"
  kms_key_id        = aws_kms_key.cmk.arn
  retention_in_days = 365
}

resource "aws_codepipeline" "main" {
  name     = var.solution_name
  role_arn = aws_iam_role.codepipeline.arn
  artifact_store {
    location = aws_s3_bucket.pipeline.bucket
    type     = "S3"
    encryption_key {
      id   = aws_kms_alias.cmk_alias.arn
      type = "KMS"
    }
  }
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = local.vcs.is_codecommit ? "CodeCommit" : "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["main"]
      configuration = local.vcs.is_codecommit ? {
        RepositoryName       = aws_codecommit_repository.pipeline[0].repository_name
        BranchName           = var.branch_name
        PollForSourceChanges = false
        OutputArtifactFormat = "CODE_ZIP"
        } : {
        ConnectionArn        = local.codestar_connection_arn
        FullRepositoryId     = var.repository_name
        BranchName           = var.branch_name
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
    }
  }
  stage {
    name = "Build"
    action {
      name            = "terraform-apply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["main"]
      configuration = {
        PrimarySource = "source"
        ProjectName   = aws_codebuild_project.main.name
      }
    }
  }
  tags = var.tags
}

resource "aws_cloudwatch_event_rule" "main" {
  count = local.vcs.is_codecommit ? 1 : 0

  name        = "${var.solution_name}-main-branch-trigger"
  description = "Rule to trigger the CodePipeline based on code changes"
  event_pattern = jsonencode({
    source      = ["aws.codecommit"]
    detail-type = ["CodeCommit Repository State Change"]
    resources   = [aws_codecommit_repository.pipeline[0].arn]
    detail = {
      event = [
        "referenceCreated",
        "referenceUpdated"
      ]
      referenceType = ["branch"]
      referenceName = [var.branch_name]
    }
  })
}

resource "aws_cloudwatch_event_target" "main" {
  count = local.vcs.is_codecommit ? 1 : 0

  rule     = aws_cloudwatch_event_rule.main[0].name
  role_arn = aws_iam_role.start_pipeline.arn
  arn      = aws_codepipeline.main.arn
}
