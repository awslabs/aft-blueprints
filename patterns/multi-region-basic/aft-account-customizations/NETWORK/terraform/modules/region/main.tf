# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

module "availability_zones" {
  source = "../../../../common/modules/network/availability_zones"

  availability_zones = var.availability_zones
  tags               = var.tags
}

module "vpc_egress" {
  source = "../../../../common/modules/network/vpc_egress"
  depends_on = [
    module.tgw,
    module.availability_zones
  ]

  identifier                     = "egress"
  region_name                    = var.region_name
  account_id                     = var.account_id
  ipam_pool_id                   = var.ipam_pool_id
  az_set                         = var.availability_zones
  transit_gateway_id             = module.tgw.transit_gateway_id
  transit_gateway_route_table_id = module.tgw.route_table_id["security"]
  enable_vpc_flow_logs           = true
  enable_central_vpc_flow_logs   = false
  tags                           = var.tags
}

module "vpc_endpoints" {
  source = "../../../../common/modules/network/vpc_shared"
  depends_on = [
    module.tgw,
    module.availability_zones,
    module.vpc_egress
  ]
  providers = {
    aws         = aws
    aws.network = aws
  }

  identifier                    = "endpoints"
  region_name                   = var.region_name
  account_id                    = var.account_id
  ipam_pool_id                  = var.ipam_pool_id
  az_set                        = var.availability_zones
  tgw_id                        = module.tgw.transit_gateway_id
  tgw_rt_association_id         = module.tgw.route_table_id["shared"]
  tgw_rt_propagation_ids        = { for rt in local.tgw_propagation_rules["shared"] : rt => module.tgw.route_table_id[rt] }
  vpc_size                      = length(var.availability_zones) <= 2 ? "medium" : "large"
  enable_vpc_flow_logs          = true
  enable_central_vpc_flow_logs  = false
  use_tgw_attachment_automation = false
  associate_dns_rules           = false
  subnets = [
    {
      name           = "private"
      newbits        = length(var.availability_zones) <= 2 ? 1 : 2
      index          = 0
      tgw_attachment = true
      vpc_endpoint   = true
    }
  ]
  vpc_tags = {
    "dns-service" = "true"
  }
  tags = var.tags
}

module "vpce" {
  source = "../../../../common/modules/network/vpce"

  vpc_id       = module.vpc_endpoints.vpc_id
  vpc_region   = var.region_name
  vpc_cidr     = module.vpc_endpoints.vpc_cidr_block
  allowed_cidr = var.region_cidr_blocks
  interface_endpoints = {
    subnet_ids = module.vpc_endpoints.subnets["private"]
    services   = var.vpc_endpoint_services
  }
}
