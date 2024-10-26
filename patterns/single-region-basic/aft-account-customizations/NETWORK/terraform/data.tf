# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

data "aws_caller_identity" "current" {}

data "aws_organizations_organization" "org" {}

data "aws_region" "primary" {
  provider = aws.primary
}

data "aws_ssm_parameter" "ct_log_archive_account_id" {
  provider = aws.aft-management
  name     = "/org/core/accounts/ct-log-archive"
}
