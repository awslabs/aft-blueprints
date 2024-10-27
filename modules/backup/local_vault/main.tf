# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_backup_vault" "backup" {
  name        = var.backup_vault_name
  kms_key_arn = aws_kms_key.backup.arn
  tags        = var.tags
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_backup_vault_policy" "backup" {
  backup_vault_name = aws_backup_vault.backup.name
  policy            = data.aws_iam_policy_document.vault.json
}

data "aws_iam_policy_document" "vault" {
  #checkov:skip=CKV_AWS_111:This is AWS Backup Vault resource policy and hence using '*' for resources
  #checkov:skip=CKV_AWS_109:This is AWS Backup Vault resource policy and hence using '*' for resources
  #checkov:skip=CKV_AWS_356:This is AWS Backup Vault resource policy and hence using '*' for resources
  statement {
    sid       = "Allow backup restore from central account"
    actions   = ["backup:CopyIntoBackupVault"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.backup_account_id}:root"]
    }
  }
}

resource "aws_backup_vault_notifications" "backup" {
  count = var.enable_backup_notifications ? 1 : 0

  backup_vault_name   = aws_backup_vault.backup.name
  sns_topic_arn       = aws_sns_topic.notify[0].arn
  backup_vault_events = var.backup_notification_events
}
