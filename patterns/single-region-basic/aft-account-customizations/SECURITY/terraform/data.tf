# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

data "aws_caller_identity" "current" {}

data "aws_organizations_organization" "org" {}

data "aws_organizations_organization" "root_ou" {
  provider = aws.org-management-primary
}
