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
    aws = aws.primary
  }

  region                = data.aws_region.primary.name
  availability_zones    = var.aws_availability_zones.primary_region
  tgw_amazon_side_asn   = "64513"
  ipam_pools            = module.ipam.pools_level_2
  region_cidr_blocks    = var.aws_ip_address_plan.primary_region.cidr_blocks
  vpc_endpoint_services = var.aws_vpc_endpoint_services
  tags                  = local.tags
}

module "secondary_region" {
  source = "./modules/region"
  providers = {
    aws = aws.secondary
  }

  region                = data.aws_region.secondary.name
  availability_zones    = var.aws_availability_zones.secondary_region
  tgw_amazon_side_asn   = "64514"
  ipam_pools            = module.ipam.pools_level_2
  region_cidr_blocks    = var.aws_ip_address_plan.secondary_region.cidr_blocks
  vpc_endpoint_services = var.aws_vpc_endpoint_services
  tags                  = local.tags
}
