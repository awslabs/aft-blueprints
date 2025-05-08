# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_s3_account_public_access_block" "account" {
  count                   = var.enable_s3_bpa ? 1 : 0
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_ec2_image_block_public_access" "account" {
  count = var.enable_ami_bpa ? 1 : 0
  state = "block-new-sharing"
}

resource "aws_ebs_encryption_by_default" "account" {
  count   = var.enforce_ebs_encryption ? 1 : 0
  enabled = true
}

resource "aws_ebs_default_kms_key" "account" {
  count   = (var.enforce_ebs_encryption && var.default_ebs_kms_key != "") ? 1 : 0
  key_arn = var.default_ebs_kms_key
}

resource "aws_ec2_instance_metadata_defaults" "enforce_imdsv2" {
  count                       = var.enforce_imdsv2 ? 1 : 0
  http_tokens                 = "required"
  http_put_response_hop_limit = 1
}
