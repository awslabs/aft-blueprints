# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_kms_key" "nfw" {
  description             = "${local.firewall_name} CMK"
  enable_key_rotation     = true
  deletion_window_in_days = 10
}

resource "aws_kms_key_policy" "nfw" {
  key_id = aws_kms_key.nfw.id
  policy = jsonencode(
    {
      Statement = [
        {
          Sid    = "Enable IAM User Permissions"
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::${var.account_id}:root"
          }
          Action   = "kms:*"
          Resource = "*"
        },
        {
          Sid    = "Allow access for Key Administrators"
          Effect = "Allow"
          Principal = {
            AWS = [
              "arn:aws:iam::${var.account_id}:role/AWSControlTowerExecution",
              "arn:aws:iam::${var.account_id}:role/AWSAFTExecution"
            ]
          }
          Action = [
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
          Resource = "*"
        }
      ]
      Version = "2008-10-17"
    }
  )
}
