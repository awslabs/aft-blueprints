# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

########################################
#######   AFT Core Parameters    #######
########################################
resource "aws_ssm_parameter" "account_id" {
  # checkov:skip=CKV_AWS_337:This SSM parameter is not a SecureString and there is no need to encrypt it using KMS
  provider = aws.aft-management

  name        = "/org/core/accounts/identity"
  type        = "String"
  description = "Delegated IAM Identity Center account Id"
  value       = data.aws_caller_identity.current.account_id
  tags        = local.tags
}

############################################
#######  Identity Center Delegation  #######
############################################
resource "aws_organizations_delegated_administrator" "sso" {
  provider = aws.org-management

  account_id        = data.aws_caller_identity.current.account_id
  service_principal = "sso.amazonaws.com"
}

########################################
#######    Pipeline Resources    #######
########################################
module "aws_ps_pipeline" {
  source = "../../common/modules/iam/permission-set-pipeline"
  providers = {
    aws.event-source-account = aws.aft-management
  }
  depends_on = [aws_organizations_delegated_administrator.sso]

  repository_name                 = var.repository_name
  branch_name                     = var.branch_name
  vcs_provider                    = var.vcs_provider
  account_lifecycle_events_source = "AFT"
  tags                            = local.tags
}


########################################
#######    IAM Access Analyzer   #######
########################################
resource "aws_organizations_delegated_administrator" "iam_access_analyzer" {
  provider = aws.org-management

  account_id        = data.aws_caller_identity.current.account_id
  service_principal = "access-analyzer.amazonaws.com"
}

module "primary_iam_access_analyzer" {
  source = "../../common/modules/iam/access-analyzer"
  providers = {
    aws = aws.primary
  }

  name = "iam-org-access-analyzer"
  type = "ORGANIZATION"
  tags = local.tags
}
