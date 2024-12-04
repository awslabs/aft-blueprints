# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

locals {
  event_rule_account_id = var.account_lifecycle_events_source == "CT" ? data.aws_organizations_organization.org[0].master_account_id : (var.account_lifecycle_events_source == "AFT" ? data.aws_ssm_parameter.aft_management_account_id[0].value : null)

  vcs = {
    is_github            = lower(var.vcs_provider) == "github" ? true : false
    is_github_enterprise = lower(var.vcs_provider) == "githubenterprise" ? true : false
  }
  codestar_connection_arn = lower(var.vcs_provider) == "github" ? aws_codestarconnections_connection.github[0].arn : aws_codestarconnections_connection.githubenterprise[0].arn
  vpc_config = var.use_code_connection && local.vcs.is_github_enterprise ? [{
    security_group_ids = var.vpc_config.security_groups
    subnets            = var.vpc_config.subnets
    vpc_id             = var.vpc_config.vpc_id
  }] : []
}
