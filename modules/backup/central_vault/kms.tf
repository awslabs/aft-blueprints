# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_kms_alias" "backup" {
  name          = "alias/aws-backup"
  target_key_id = aws_kms_key.backup.key_id
}

resource "aws_kms_key" "backup" {
  description         = "Backup Vault CMK"
  enable_key_rotation = "true"
  policy              = data.aws_iam_policy_document.kms.json
  tags                = var.tags
  lifecycle {
    prevent_destroy = false
  }
}

data "aws_iam_policy_document" "kms" {
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
    sid = "Allow use of the key"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.org.id]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values = [
        "arn:aws:iam::*:role/aws-service-role/backup.amazonaws.com/AWSServiceRoleForBackup",
        "arn:aws:iam::*:role/${local.backup_operator_role_name}",
        "arn:aws:iam::*:role/${local.backup_restore_role_name}"
      ]
    }
  }
  statement {
    sid = "Allow attachment of persistent resources by the centralizes AWS Backup Account"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.org.id]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values = [
        "arn:aws:iam::*:role/aws-service-role/backup.amazonaws.com/AWSServiceRoleForBackup",
        "arn:aws:iam::*:role/${local.backup_operator_role_name}",
        "arn:aws:iam::*:role/${local.backup_restore_role_name}"
      ]
    }
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}
