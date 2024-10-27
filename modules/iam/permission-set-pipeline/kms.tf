# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_kms_key" "cmk" {
  description         = "KMS for permission set pipeline"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.cmk_policy.json
  tags                = var.tags
}

resource "aws_kms_alias" "cmk_alias" {
  name          = "alias/${var.solution_name}"
  target_key_id = aws_kms_key.cmk.key_id
}

data "aws_iam_policy_document" "cmk_policy" {
  #checkov:skip=CKV_AWS_111:This is KMS resource policy and hence using '*' for resources
  #checkov:skip=CKV_AWS_109:This is KMS resource policy and hence using '*' for resources
  #checkov:skip=CKV_AWS_356:This is KMS resource policy and hence using '*' for resources
  statement {
    sid       = "Enable IAM User Permissions"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
  statement {
    sid = "Allow access for Key Administrators"
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
      "kms:CancelKeyDeletion"
    ]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSControlTowerExecution",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSAFTExecution"
      ]
    }
  }
  statement {
    sid = "Allow use of the key"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        "${aws_iam_role.codebuild.arn}",
        "${aws_iam_role.codepipeline.arn}"
      ]
    }
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }
  }
}

