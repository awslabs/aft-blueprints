# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

########################################
#######   AFT Core Parameters    #######
########################################
resource "aws_ssm_parameter" "account_id" {
  # checkov:skip=CKV_AWS_337:This SSM parameter is not a SecureString and there is no need to encrypt it using KMS
  provider = aws.aft-management

  name        = "/org/core/accounts/ct-security-tooling"
  type        = "String"
  description = "Control Tower Security Tooling account Id"
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
# https://github.com/hashicorp/terraform-provider-aws/issues/39687
resource "aws_securityhub_organization_admin_account" "securityhub" {
  provider   = aws.org-management-primary
  depends_on = [aws_securityhub_account.primary]

  admin_account_id = data.aws_caller_identity.current.account_id
}

resource "aws_securityhub_account" "primary" {
  provider = aws.primary

  control_finding_generator = var.securityhub_control_finding_generator
}

############################################
#######         Security Hub         #######
############################################
module "securityhub" {
  source = "../../common/modules/security/securityhub"
  depends_on = [
    aws_securityhub_organization_admin_account.securityhub
  ]

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

  name                  = "default-policy"
  description           = "Default policy for organization"
  service_enabled       = true
  enabled_standard_arns = var.securityhub_enabled_standard_arns
  association_targets   = [data.aws_organizations_organization.root_ou.roots[0].id]
}

##################################################
#######     Organization Policy Pipeline   #######
##################################################
# Creates AWS Organization Policy (RCP/SCP) pipeline
module "securityhub_default_policy" {
  source     = "../../common/modules/security/organizations_policy_pipeline"

  providers = aws.primary

  project_name = "org-policy-mgmt"

  terraform_version    = "1.9.8"
  enable_bedrock       = true
  bedrock_model_id       = "global.anthropic.claude-sonnet-4-20250514-v1:0"
  provider_type        = "GitHub"
  full_repository_name = "myorg/org-policy-mgmt-pipeline"
  branch_name          = "main"
  security_gate = [
    "ERROR", "SECURITY_WARNING"
  ]
  tags = local.tags
}
