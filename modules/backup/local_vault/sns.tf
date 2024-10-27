# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_sns_topic" "notify" {
  count = var.enable_backup_notifications ? 1 : 0

  name              = "aws-backup-notifications"
  display_name      = "aws-backup-notifications"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_policy" "notify" {
  count = var.enable_backup_notifications ? 1 : 0

  arn    = aws_sns_topic.notify[0].arn
  policy = data.aws_iam_policy_document.notify[0].json
}

data "aws_iam_policy_document" "notify" {
  count = var.enable_backup_notifications ? 1 : 0

  statement {
    actions = ["sns:Publish"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
    resources = [aws_sns_topic.notify[0].arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}
