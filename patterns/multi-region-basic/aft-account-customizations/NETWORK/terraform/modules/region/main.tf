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

  ipam_pool_id                   = var.ipam_pools["${var.region}/shared"].id
  az_set                         = var.availability_zones
  transit_gateway_id             = module.tgw.transit_gateway_id
  transit_gateway_route_table_id = module.tgw.route_table_id["egress"]
  tags                           = var.tags
}

module "vpc_endpoints" {
  source = "../../../../common/modules/network/vpc_endpoints"
  depends_on = [
    module.tgw,
    module.availability_zones,
    module.vpc_egress
  ]

  ipam_pool_id                   = var.ipam_pools["${var.region}/shared"].id
  az_set                         = var.availability_zones
  transit_gateway_id             = module.tgw.transit_gateway_id
  transit_gateway_route_table_id = module.tgw.route_table_id["shared"]
  transit_gateway_propagations   = { for rt in local.tgw_propagation_rules["shared"] : rt => module.tgw.route_table_id[rt] }
  subnets = [
    {
      name           = "r53e"
      newbits        = 5
      index          = 0
      tgw_attachment = true
    },
    {
      name         = "vpce"
      newbits      = 3
      index        = 4
      vpc_endpoint = true
    }
  ]
  tags = var.tags
}

module "vpce" {
  source = "../../../../common/modules/network/vpce"

  vpc_id       = module.vpc_endpoints.vpc_id
  vpc_name     = "endpoints-vpc"
  allowed_cidr = var.region_cidr_blocks
  interface_endpoints = {
    subnet_ids = module.vpc_endpoints.subnets["vpce"]
    services   = var.vpc_endpoint_services
  }
}
