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

  ipam_pool_id                   = var.ipam_pools["${local.region}/shared"].id
  az_set                         = var.availability_zones
  transit_gateway_id             = module.tgw.transit_gateway_id
  transit_gateway_route_table_id = module.tgw.route_table_id["egress"]
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

  identifier                   = "endpoints"
  vpc_size                     = length(var.availability_zones) <= 2 ? "medium" : "large"
  ipam_pool_id                 = var.ipam_pools["${local.region}/shared"].id
  az_set                       = var.availability_zones
  tgw_id                       = module.tgw.transit_gateway_id
  tgw_rt_association_id        = module.tgw.route_table_id["shared"]
  tgw_rt_propagations          = { for rt in local.tgw_propagation_rules["shared"] : rt => module.tgw.route_table_id[rt] }
  enable_vpc_flow_logs         = true
  enable_central_vpc_flow_logs = false
  associate_dns_rules          = false
  use_tgw_id_parameter         = false
  use_propagation_rules        = false
  subnets = [
    {
      name           = "private"
      newbits        = length(var.availability_zones) <= 2 ? 1 : 2
      index          = 0
      tgw_attachment = true
      vpc_endpoint   = true
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
    subnet_ids = module.vpc_endpoints.subnets["private"]
    services   = var.vpc_endpoint_services
  }
  gateway_endpoints = {
    route_table_ids = module.vpc_endpoints.route_tables["private"]
    services        = ["s3"]
  }
}
