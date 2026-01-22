# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

## +-------
## | S3 - CodeBuild Artifacts & Scripts
## +---------------------------------

resource "aws_s3_bucket" "artifacts" {
  # checkov:skip=CKV2_AWS_62:Events notification is optional for this solution
  # checkov:skip=CKV_AWS_144:Cross-region replication is not required for this solution
  # checkov:skip=CKV_AWS_18:Bucket access logging is optional for this solution
  bucket        = "${var.project_name}-artifacts-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.pipeline_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "SecureBucketPolicy"
    Statement = [
      {
        Sid       = "DenyNonHttpsAccess"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "${aws_s3_bucket.artifacts.arn}",
          "${aws_s3_bucket.artifacts.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "artifacts" {
  # checkov:skip=CKV_AWS_300:There are no multipart uploads in this solution
  bucket = aws_s3_bucket.artifacts.id

  rule {
    id     = "expire_all_objects"
    status = "Enabled"

    expiration {
      days = 365
    }

    noncurrent_version_expiration {
      noncurrent_days = 365
    }
  }
}


## +-------
## | S3 Objects - Upload scripts to bucket
## +---------------------------------

data "archive_file" "init" {
  type        = "zip"
  source_dir  = "${path.module}/source/"
  output_path = "${path.module}/source.zip"
}

resource "aws_s3_object" "object" {
  depends_on = [data.archive_file.init]
  bucket     = aws_s3_bucket.artifacts.id
  key        = "scripts/source.zip"
  source     = data.archive_file.init.output_path
  etag       = filemd5(data.archive_file.init.output_path)
}

## +-------
## | S3 - Terraform State
## +---------------------------------

resource "aws_s3_bucket" "tfstate" {
  # checkov:skip=CKV2_AWS_62:Events notification is optional for this solution
  # checkov:skip=CKV_AWS_144:Cross-region replication is not required for this solution
  # checkov:skip=CKV_AWS_18:Bucket access logging is optional for this solution
  bucket        = "${var.project_name}-tfstate-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.pipeline_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "SecureBucketPolicy"
    Statement = [
      {
        Sid       = "DenyNonHttpsAccess"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "${aws_s3_bucket.tfstate.arn}",
          "${aws_s3_bucket.tfstate.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "tfstate" {
  # checkov:skip=CKV_AWS_300:There are no multipart uploads in this solution
  bucket = aws_s3_bucket.tfstate.id

  rule {
    id     = "expire_all_objects"
    status = "Enabled"

    expiration {
      days = 365
    }

    noncurrent_version_expiration {
      noncurrent_days = 365
    }
  }
}