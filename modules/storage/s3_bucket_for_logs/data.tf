# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

data "aws_organizations_organization" "org" {
  count = length(var.aws_organization_service_principals) > 0 ? 1 : 0
}

data "aws_iam_policy_document" "custodian_s3_bucket_policy" {
  #checkov:skip=CKV_AWS_108:This is a resource policy and is associated only with this resource.
  #checkov:skip=CKV_AWS_109:This is a resource policy and is associated only with this resource.
  #checkov:skip=CKV_AWS_111:This is a resource policy and is associated only with this resource.
  statement {
    sid     = "DenyNonTLSConnections"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      "${aws_s3_bucket.this.arn}",
      "${aws_s3_bucket.this.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
  dynamic "statement" {
    for_each = length(var.aws_organization_service_principals) > 0 ? [1] : []
    content {
      sid       = "AllowOrganizationLevelWrite"
      effect    = "Allow"
      actions   = ["s3:PutObject"]
      resources = ["${aws_s3_bucket.this.arn}/*"]
      principals {
        type        = "Service"
        identifiers = var.aws_organization_service_principals
      }
      condition {
        test     = "StringEquals"
        variable = "aws:SourceOrgID"
        values   = [data.aws_organizations_organization.org[0].id]
      }
      condition {
        test     = "StringEquals"
        variable = "s3:x-amz-acl"
        values   = ["bucket-owner-full-control"]
      }
    }
  }
  dynamic "statement" {
    for_each = length(var.aws_organization_service_principals) > 0 ? [1] : []
    content {
      sid       = "AllowOrganizationLevelCheck"
      effect    = "Allow"
      actions   = ["s3:GetBucketAcl"]
      resources = [aws_s3_bucket.this.arn]
      principals {
        type        = "Service"
        identifiers = var.aws_organization_service_principals
      }
      condition {
        test     = "StringEquals"
        variable = "aws:SourceOrgID"
        values   = [data.aws_organizations_organization.org[0].id]
      }
    }
  }
}
