# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.custodian_s3_bucket_policy.json
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.aws_kms_customer_managed_key == "" ? null : var.aws_kms_customer_managed_key
      sse_algorithm     = var.aws_kms_customer_managed_key == "" ? "AES256" : "aws:kms"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  depends_on = [aws_s3_bucket_versioning.this]

  bucket = aws_s3_bucket.this.id
  rule {
    id = "LifecycleRule"
    expiration {
      days = var.expiration_days
    }
    dynamic "transition" {
      for_each = var.transition_rules
      content {
        days          = transition.value.days
        storage_class = transition.value.storage_class
      }
    }
    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }
    dynamic "noncurrent_version_transition" {
      for_each = var.noncurrent_version_transition_rules
      content {
        noncurrent_days = noncurrent_version_transition.value.noncurrent_days
        storage_class   = noncurrent_version_transition.value.storage_class
      }
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = var.abort_incomplete_multipart_upload_days
    }
    status = "Enabled"
  }
}
