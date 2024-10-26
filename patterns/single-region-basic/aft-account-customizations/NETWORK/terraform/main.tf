# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

########################################
#######   AFT Core Parameters    #######
########################################
resource "aws_ssm_parameter" "account_id" {
  # checkov:skip=CKV_AWS_337:This SSM parameter is not a SecureString and there is no need to encrypt it using KMS
  provider = aws.aft-management

  name        = "/org/core/accounts/network"
  type        = "String"
  description = "Network Account Id"
  value       = data.aws_caller_identity.current.account_id
  tags        = local.tags
}

########################################
#######    Regional Resources    #######
########################################
module "primary_region" {
  source = "./modules/region"
  providers = {
    aws             = aws.primary
    aws.log-archive = aws.log-archive-primary
  }

  availability_zones = var.aws_availability_zones.primary_region
  ipam_pools         = module.ipam.pools_level_2
  tags               = local.tags
}
