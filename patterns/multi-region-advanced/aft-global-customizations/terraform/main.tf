# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

#############################################################################
#
# This code deploys an IAM Password Policy within a AWS account.
# It is a global configuration, so only needs to be deployed once for an account.
# Recommendation is in the home region of the AFT solution, and as it is only
# one terraform resource a module is not needed.
#
#############################################################################
resource "aws_iam_account_password_policy" "strict" {
  allow_users_to_change_password = "true"
  hard_expiry                    = "false"
  max_password_age               = "90"
  minimum_password_length        = "14"
  password_reuse_prevention      = "24"
  require_lowercase_characters   = "true"
  require_numbers                = "true"
  require_symbols                = "true"
  require_uppercase_characters   = "true"
}

#############################################################################
#
# This code deploys account level security configuration, including:
# - S3 Block Public Access
# - AMI Block Public Access
# - EBS Encryption Enforcement
# - IMDSv2 Enforcement
#
#############################################################################
module "default_account_config_primary" {
  source = "./modules/default_account_config"
  providers = {
    aws = aws.primary
  }

  enable_s3_bpa          = lookup(local.features, "s3_bpa", true)
  enable_ami_bpa         = lookup(local.features, "ami_bpa", true)
  enforce_ebs_encryption = lookup(local.features, "ebs_encryption", true)
  enforce_imdsv2         = lookup(local.features, "imdsv2", true)
}

module "default_account_config_secondary" {
  source = "./modules/default_account_config"
  providers = {
    aws = aws.secondary
  }

  enable_s3_bpa          = false # It is a global configuration, so only needs to be deployed once for an account
  enable_ami_bpa         = lookup(local.features, "ami_bpa", true)
  enforce_ebs_encryption = lookup(local.features, "ebs_encryption", true)
  enforce_imdsv2         = lookup(local.features, "imdsv2", true)
}
