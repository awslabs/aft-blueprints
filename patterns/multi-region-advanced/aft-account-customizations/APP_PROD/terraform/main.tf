# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

module "primary_region" {
  source = "./blueprint"
  count  = contains(local.regions, "primary") ? 1 : 0

  providers = {
    aws         = aws.primary
    aws.network = aws.network-primary
  }

  create_phz         = true #creating Route 53 PHZ only in the primary region, as it is a global resource
  phz_name           = local.phz_name
  vpc                = local.vpc
  backup_account_id  = data.aws_ssm_parameter.backup_account_id.value
  create_backup_role = true
  tags               = local.tags
}

module "secondary_region" {
  source = "./blueprint"
  count  = contains(local.regions, "secondary") ? 1 : 0

  providers = {
    aws         = aws.secondary
    aws.network = aws.network-secondary
  }

  phz_name          = local.phz_name
  vpc               = local.vpc
  backup_account_id = data.aws_ssm_parameter.backup_account_id.value
  tags              = local.tags
}
