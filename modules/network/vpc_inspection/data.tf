# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "nfw_kms_policy" {
  #checkov:skip=CKV_AWS_109:This is a resource policy so it's attach only to this resource.
  #checkov:skip=CKV_AWS_111:This is a resource policy so it's attach only to this resource.
  #checkov:skip=CKV_AWS_356:This is KMS resource policy and hence using '*' for resources
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
  statement {
    sid       = "Allow access for Key Administrators"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSControlTowerExecution",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSAFTExecution"
      ]
    }
  }
}

data "aws_ssm_parameter" "central_vpc_flow_logs_s3_bucket_arn" {
  count    = var.enable_central_vpc_flow_logs ? 1 : 0
  provider = aws.network

  name = "/org/core/network/vpc-flow-logs/s3-bucket-arn"
}
