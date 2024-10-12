# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

module "availability_zones" {
  source = "../../../../common/modules/network/availability_zones"

  availability_zones = var.availability_zones
  tags               = var.tags
}

module "vpc_inspection" {
  source = "../../../../common/modules/network/vpc_inspection"
  depends_on = [
    module.tgw,
    module.availability_zones
  ]

  ipam_pool_id                   = var.ipam_pools["${var.region}/shared"].id
  az_set                         = var.availability_zones
  transit_gateway_id             = module.tgw.transit_gateway_id
  transit_gateway_route_table_id = module.tgw.route_table_id["inspection"]
  enable_egress                  = true
  network_firewall_config = {
    home_net                           = var.private_cidr_blocks
    stateless_default_actions          = "aws:forward_to_sfe"
    stateless_fragment_default_actions = "aws:forward_to_sfe"
    flow_log                           = true
    alert_log                          = true
  }
  tags = var.tags
}

module "vpc_endpoints" {
  source = "../../../../common/modules/network/vpc_endpoints"
  depends_on = [
    module.tgw,
    module.availability_zones,
    module.vpc_inspection
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
  vpc_cidr     = module.vpc_endpoints.vpc_cidr_block
  allowed_cidr = var.region_cidr_blocks
  interface_endpoints = {
    subnet_ids = module.vpc_endpoints.subnets["vpce"]
    services   = var.vpc_endpoint_services
  }
}
