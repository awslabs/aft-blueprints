# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_s3_bucket" "pipeline" {
  #checkov:skip=CKV2_AWS_62: This bucket does not use event notifications
  #checkov:skip=CKV2_AWS_61: This bucket does not need a lifecycle configuration
  #checkov:skip=CKV_AWS_144: This bucket does not need cross-region replication enabled
  #checkov:skip=CKV_AWS_18: This bucket does not need access logging enabled  
  bucket = "${var.solution_name}-codebuild-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "pipeline" {
  bucket                  = aws_s3_bucket.pipeline.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "pipeline" {
  bucket = aws_s3_bucket.pipeline.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "pipeline" {
  bucket = aws_s3_bucket.pipeline.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.cmk.key_id
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket" "tf_backend" {
  #checkov:skip=CKV2_AWS_62: This bucket does not use event notifications
  #checkov:skip=CKV2_AWS_61: This bucket does not need a lifecycle configuration
  #checkov:skip=CKV_AWS_144: This bucket does not need cross-region replication enabled
  #checkov:skip=CKV_AWS_18: This bucket does not need access logging enabled
  bucket = "${var.solution_name}-tf-backend-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "tf_backend" {
  bucket                  = aws_s3_bucket.tf_backend.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "tf_backend" {
  bucket = aws_s3_bucket.tf_backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_backend_encryption" {
  bucket = aws_s3_bucket.tf_backend.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.cmk.key_id
      sse_algorithm     = "aws:kms"
    }
  }
}
