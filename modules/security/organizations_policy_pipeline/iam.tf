# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

## +-------
## | IAM - CodePipeline execution role
## +---------------------------------

resource "aws_iam_role" "codepipeline_role" {
  name = "${var.project_name}-pipeline-role"
  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.project_name}-pipeline"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketAcl"
        ]
        Resource = [
          "${aws_s3_bucket.artifacts.arn}",
          "${aws_s3_bucket.artifacts.arn}/*",
          "${aws_s3_bucket.tfstate.arn}/*",
          "${aws_s3_bucket.tfstate.arn}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ]
        Resource = aws_kms_key.pipeline_key.arn
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish",
        ]
        Resource = aws_sns_topic.approval_notification.arn
      },
      {
        Effect = "Allow"
        Action = [
          "codeconnections:UseConnection",
          "codestar-connections:UseConnection"
        ]
        Resource = aws_codestarconnections_connection.connection.arn
      }
    ]
  })
}

## +-------
## | IAM - CodeBuild execution roles for plan & apply steps
## +---------------------------------

resource "aws_iam_role" "codebuild_role_plan" {
  name = "${var.project_name}-codebuild-role-plan"
  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_policy_plan" {
  # checkov:skip=CKV_AWS_290:Permission required since this role will create different log groups
  # checkov:skip=CKV_AWS_355:Permission required since this role will create different log groups
  name = "${var.project_name}-codebuild-policy-plan"
  role = aws_iam_role.codebuild_role_plan.id


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.artifacts.arn}/*",
          "${aws_s3_bucket.tfstate.arn}/*",
          "${aws_s3_bucket.tfstate.arn}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ]
        Resource = aws_kms_key.pipeline_key.arn
      },
      {
        Effect = "Allow"
        Action = [
          "access-analyzer:CheckNoNewAccess",
          "access-analyzer:ValidatePolicy",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "Organizations:ListAccounts",
          "Organizations:DescribePolicy",
          "Organizations:ListTagsForResource",
          "Organizations:ListTargetsForPolicy",
          "Bedrock:InvokeModel",
          "Bedrock:InvokeModelWithResponseStream"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "codebuild_role_apply" {
  name = "${var.project_name}-codebuild-role-apply"
  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_policy_apply" {
  # checkov:skip=CKV_AWS_290:Permission required since this role will create different log groups
  # checkov:skip=CKV_AWS_355:Permission required since this role will create different log groups  
  name = "${var.project_name}-codebuild-policy-apply"
  role = aws_iam_role.codebuild_role_apply.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.artifacts.arn}/*",
          "${aws_s3_bucket.tfstate.arn}/*",
          "${aws_s3_bucket.tfstate.arn}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ]
        Resource = aws_kms_key.pipeline_key.arn
      },
      {
        Effect = "Allow"
        Action = [
          "Organizations:CreatePolicy",
          "Organizations:AttachPolicy",
          "Organizations:DescribePolicy",
          "Organizations:DetachPolicy",
          "Organizations:UpdatePolicy",
          "Organizations:DeletePolicy",
          "Organizations:ListTagsForResource",
          "Organizations:ListTargetsForPolicy"
        ]
        Resource = "*"
      }
    ]
  })
}