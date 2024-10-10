# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

########################################
#######   AFT Core Parameters    #######
########################################
resource "aws_ssm_parameter" "account_id" {
  # checkov:skip=CKV_AWS_337:This SSM parameter is not a SecureString and there is no need to encrypt it using KMS
  provider = aws.aft-management

  name        = "/org/core/accounts/security"
  type        = "String"
  description = "Security Tooling account Id"
  value       = data.aws_caller_identity.current.account_id
  tags        = local.tags
}

############################################
#######     GuardDuty delegation     #######
############################################
resource "aws_guardduty_organization_admin_account" "primary" {
  provider = aws.org-management-primary

  admin_account_id = data.aws_caller_identity.current.account_id
}

resource "aws_guardduty_organization_admin_account" "secondary" {
  provider = aws.org-management-secondary

  admin_account_id = data.aws_caller_identity.current.account_id
}

########################################
#######         GuardDuty        #######
########################################
module "primary_guardduty" {
  source     = "../../common/modules/security/guardduty"
  depends_on = [aws_guardduty_organization_admin_account.primary]
  providers = {
    aws = aws.primary
  }

  auto_enable_organization_members = var.guardduty_auto_enable_organization_members
}

module "secondary_guardduty" {
  source     = "../../common/modules/security/guardduty"
  depends_on = [aws_guardduty_organization_admin_account.secondary]
  providers = {
    aws = aws.secondary
  }

  auto_enable_organization_members = var.guardduty_auto_enable_organization_members
}


############################################
#######   Security Hub delegation    #######
############################################
# aws_securityhub_account is necessary to enable consolidated control findings feature, 
# as Terraform resources for securityhub organization configuration level don't support set up it.
# https://github.com/hashicorp/terraform-provider-aws/issues/30022
# https://github.com/hashicorp/terraform-provider-aws/pull/30692
resource "aws_securityhub_organization_admin_account" "securityhub" {
  provider = aws.org-management-primary
  depends_on = [
    aws_securityhub_account.primary,
    aws_securityhub_account.secondary,
    aws_securityhub_account.primary_org_management,
    aws_securityhub_account.secondary_org_management
  ]

  admin_account_id = data.aws_caller_identity.current.account_id
}

resource "aws_securityhub_account" "primary" {
  provider = aws.primary

  control_finding_generator = var.securityhub_control_finding_generator
}

resource "aws_securityhub_account" "secondary" {
  provider = aws.secondary

  control_finding_generator = var.securityhub_control_finding_generator
}

# Enabling securityhub in the organizations management account, since it's not enabled by default
resource "aws_securityhub_account" "primary_org_management" {
  provider = aws.org-management-primary

  control_finding_generator = var.securityhub_control_finding_generator
}

resource "aws_securityhub_account" "secondary_org_management" {
  provider = aws.org-management-secondary

  control_finding_generator = var.securityhub_control_finding_generator
}

############################################
#######         Security Hub         #######
############################################
module "securityhub" {
  source     = "../../common/modules/security/securityhub"
  depends_on = [aws_securityhub_organization_admin_account.securityhub]

  configuration_type = "CENTRAL"
  linking_mode       = "SPECIFIED_REGIONS"
  specified_regions = [
    data.aws_region.secondary.name
  ]
}


############################################
#######     Security Hub Policies    #######
############################################
# Applying a default security policy to all members of the organization
module "securityhub_default_policy" {
  source     = "../../common/modules/security/securityhub_policy"
  depends_on = [module.securityhub]

  name            = "default-policy"
  description     = "Default policy for organization"
  service_enabled = true
  enabled_standard_arns = [
    "arn:aws:securityhub:us-east-1::standards/aws-foundational-security-best-practices/v/1.0.0",
    "arn:aws:securityhub:us-east-1::standards/cis-aws-foundations-benchmark/v/3.0.0"
  ]
  association_targets = [data.aws_organizations_organization.org.roots[0].id]
}
