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
