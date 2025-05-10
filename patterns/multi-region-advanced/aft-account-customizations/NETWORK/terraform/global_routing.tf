# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

########################################
#######   TGW Global Resources   #######
########################################

module "tgw_peering_primary_to_secondary" {
  source = "../../common/modules/network/tgw_peering"
  depends_on = [
    module.primary_region,
    module.secondary_region
  ]
  providers = {
    aws.peer-requester = aws.primary
    aws.peer-accepter  = aws.secondary
  }

  tgw_requester_id             = module.primary_region.tgw_id
  tgw_requester_route_table_id = module.primary_region.tgw_route_table_id["gateway"]
  tgw_requester_region         = data.aws_region.primary.name
  tgw_accepter_id              = module.secondary_region.tgw_id
  tgw_accepter_route_table_id  = module.secondary_region.tgw_route_table_id["gateway"]
  tgw_accepter_region          = data.aws_region.secondary.name
  tags                         = local.tags
}

module "primary_tgw_peering_routing" {
  source = "../../common/modules/network/tgw_routing"
  providers = {
    aws = aws.primary
  }

  routing_config = {
    inspection = {
      tgw_route_table_id = module.primary_region.tgw_route_table_id["security"]
      routes = [
        {
          destination_cidr_blocks = var.aws_ip_address_plan.secondary_region.cidr_blocks
          tgw_attachment_id       = module.tgw_peering_primary_to_secondary.tgw_attachment_id
        }
      ]
    }
    gateway = {
      tgw_route_table_id = module.primary_region.tgw_route_table_id["gateway"]
      routes = [
        {
          destination_cidr_blocks = var.aws_ip_address_plan.primary_region.cidr_blocks
          tgw_attachment_id       = module.primary_region.inspection_vpc_tgw_attachment_id
        }
      ]
    }
  }
}

module "secondary_tgw_peering_routing" {
  source = "../../common/modules/network/tgw_routing"
  providers = {
    aws = aws.secondary
  }

  routing_config = {
    inspection = {
      tgw_route_table_id = module.secondary_region.tgw_route_table_id["security"]
      routes = [
        {
          destination_cidr_blocks = var.aws_ip_address_plan.primary_region.cidr_blocks
          tgw_attachment_id       = module.tgw_peering_primary_to_secondary.tgw_attachment_id
        }
      ]
    }
    gateway = {
      tgw_route_table_id = module.secondary_region.tgw_route_table_id["gateway"]
      routes = [
        {
          destination_cidr_blocks = var.aws_ip_address_plan.secondary_region.cidr_blocks
          tgw_attachment_id       = module.secondary_region.inspection_vpc_tgw_attachment_id
        }
      ]
    }
  }
}


########################################
#######   DX Global Resources    #######
########################################

module "dx_gateway" {
  source = "../../common/modules/network/dx_gateway"

  gateway_name = var.aws_dx_info.gateway_name
  bgp_asn      = var.aws_dx_info.bgp_asn
}

module "primary_dx_gw_association" {
  source = "../../common/modules/network/dx_gateway_association"
  providers = {
    aws = aws.primary
  }

  dx_gateway_id         = module.dx_gateway.id
  associated_gateway_id = module.primary_region.tgw_id
  allowed_prefixes      = var.aws_ip_address_plan.primary_region.cidr_blocks
  tgw_rt_association    = module.primary_region.tgw_route_table_id["gateway"]
  tgw_rt_propagations   = { "security" = module.primary_region.tgw_route_table_id["security"] }
}

module "secondary_dx_gw_association" {
  source = "../../common/modules/network/dx_gateway_association"
  providers = {
    aws = aws.secondary
  }

  dx_gateway_id         = module.dx_gateway.id
  associated_gateway_id = module.secondary_region.tgw_id
  allowed_prefixes      = var.aws_ip_address_plan.secondary_region.cidr_blocks
  tgw_rt_association    = module.secondary_region.tgw_route_table_id["gateway"]
  tgw_rt_propagations   = { "security" = module.secondary_region.tgw_route_table_id["security"] }
}
