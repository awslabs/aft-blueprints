# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

module "primary_region" {
  source = "./blueprint"

  providers = {
    aws         = aws.primary
    aws.network = aws.network-primary
  }

  phz_name           = local.phz_name
  vpc                = local.vpc
  backup_account_id  = data.aws_ssm_parameter.backup_account_id.value
  create_backup_role = true
  tags               = local.tags
}
