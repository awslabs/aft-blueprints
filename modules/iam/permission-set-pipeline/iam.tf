# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_iam_role" "start_pipeline" {
  name_prefix        = "${var.solution_name}-${var.branch_name}-trigger-role"
  assume_role_policy = file("${path.module}/assets/trust-policies/events.json")
}

resource "aws_iam_role_policy" "start_pipeline" {
  name = "${var.solution_name}-codepipeline-policy"
  role = aws_iam_role.start_pipeline.id
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["codepipeline:StartPipelineExecution"]
          Effect   = "Allow"
          Resource = aws_codepipeline.this.arn
        }
      ]
    }
  )
}

resource "aws_iam_role" "codebuild" {
  name                  = "${var.solution_name}-codebuild-role"
  assume_role_policy    = file("${path.module}/assets/trust-policies/codebuild.json")
  force_detach_policies = true
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${var.solution_name}-codebuild-policy"
  role = aws_iam_role.codebuild.id
  policy = templatefile("${path.module}/assets/role-policies/codebuild_role_policy.json", {
    region                   = data.aws_region.current.name
    account_id               = data.aws_caller_identity.current.account_id
    solution_name            = var.solution_name
    pipeline_bucket_arn      = aws_s3_bucket.pipeline.arn
    tf_backend_bucket_arn    = aws_s3_bucket.tf_backend.arn
    tf_backend_ddb_table_arn = aws_dynamodb_table.tf_backend.arn
  })
}

resource "aws_iam_role_policy" "codebuild_identity_center_policy" {
  name   = "IdentityCenterPolicy"
  role   = aws_iam_role.codebuild.id
  policy = file("${path.module}/assets/role-policies/identity_center_role_policy.json")
}

resource "aws_iam_role" "codepipeline" {
  name                  = "${var.solution_name}-codepipeline-role"
  assume_role_policy    = file("${path.module}/assets/trust-policies/codepipeline.json")
  force_detach_policies = true
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.solution_name}-codepipeline-policy"
  role = aws_iam_role.codepipeline.id
  policy = templatefile("${path.module}/assets/role-policies/codepipeline_role_policy.json", {
    region              = data.aws_region.current.name
    account_id          = data.aws_caller_identity.current.account_id
    solution_name       = var.solution_name
    pipeline_bucket_arn = aws_s3_bucket.pipeline.arn
  })
}

resource "aws_iam_role" "lambda" {
  count    = var.account_lifecycle_events_source == "AFT" ? 1 : 0
  provider = aws.event-source-account

  name                  = "${var.solution_name}-lambda-role"
  assume_role_policy    = file("${path.module}/assets/trust-policies/lambda.json")
  force_detach_policies = true
}

resource "aws_iam_role_policy" "lambda_policy" {
  count    = var.account_lifecycle_events_source == "AFT" ? 1 : 0
  provider = aws.event-source-account

  name = "${var.solution_name}-lambda-policy"
  role = aws_iam_role.lambda[0].id
  policy = templatefile("${path.module}/assets/role-policies/lambda_role_policy.json", {
    region        = data.aws_region.current.name
    account_id    = data.aws_ssm_parameter.aft_management_account_id[0].value
    event_bus_arn = aws_cloudwatch_event_bus.pipeline[0].arn
  })
}
