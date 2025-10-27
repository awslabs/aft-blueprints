# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

## +-------
## | KMS - Key for pipeline encryption
## +---------------------------------

resource "aws_kms_key" "pipeline_key" {
  description             = "KMS key for pipeline encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

resource "aws_kms_alias" "pipeline_key_alias" {
  name          = "alias/${var.project_name}-key"
  target_key_id = aws_kms_key.pipeline_key.key_id
}