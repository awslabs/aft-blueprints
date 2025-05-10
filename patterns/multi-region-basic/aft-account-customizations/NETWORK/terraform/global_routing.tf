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
  tgw_requester_route_table_id = module.primary_region.tgw_route_table_id["security"]
  tgw_requester_region         = data.aws_region.primary.name
  tgw_accepter_id              = module.secondary_region.tgw_id
  tgw_accepter_route_table_id  = module.secondary_region.tgw_route_table_id["security"]
  tgw_accepter_region          = data.aws_region.secondary.name
  tags                         = local.tags
}

module "primary_tgw_peering_routing" {
  source = "../../common/modules/network/tgw_routing"
  providers = {
    aws = aws.primary
  }

  routing_config = {
    shared = {
      tgw_route_table_id = module.primary_region.tgw_route_table_id["shared"]
      routes = [
        {
          destination_cidr_blocks = var.aws_ip_address_plan.secondary_region.cidr_blocks
          tgw_attachment_id       = module.tgw_peering_primary_to_secondary.tgw_attachment_id
        }
      ]
    }
    prod = {
      tgw_route_table_id = module.primary_region.tgw_route_table_id["prod"]
      routes = [
        {
          destination_cidr_blocks = var.aws_ip_address_plan.secondary_region.prod.cidr_blocks
          tgw_attachment_id       = module.tgw_peering_primary_to_secondary.tgw_attachment_id
        },
        {
          destination_cidr_blocks = var.aws_ip_address_plan.secondary_region.shared.cidr_blocks
          tgw_attachment_id       = module.tgw_peering_primary_to_secondary.tgw_attachment_id
        }
      ]
    }
    stage = {
      tgw_route_table_id = module.primary_region.tgw_route_table_id["stage"]
      routes = [
        {
          destination_cidr_blocks = var.aws_ip_address_plan.secondary_region.stage.cidr_blocks
          tgw_attachment_id       = module.tgw_peering_primary_to_secondary.tgw_attachment_id
        },
        {
          destination_cidr_blocks = var.aws_ip_address_plan.secondary_region.shared.cidr_blocks
          tgw_attachment_id       = module.tgw_peering_primary_to_secondary.tgw_attachment_id
        }
      ]
    }
    dev = {
      tgw_route_table_id = module.primary_region.tgw_route_table_id["dev"]
      routes = [
        {
          destination_cidr_blocks = var.aws_ip_address_plan.secondary_region.dev.cidr_blocks
          tgw_attachment_id       = module.tgw_peering_primary_to_secondary.tgw_attachment_id
        },
        {
          destination_cidr_blocks = var.aws_ip_address_plan.secondary_region.shared.cidr_blocks
          tgw_attachment_id       = module.tgw_peering_primary_to_secondary.tgw_attachment_id
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
    shared = {
      tgw_route_table_id = module.secondary_region.tgw_route_table_id["shared"]
      routes = [
        {
          destination_cidr_blocks = var.aws_ip_address_plan.primary_region.cidr_blocks
          tgw_attachment_id       = module.tgw_peering_primary_to_secondary.tgw_attachment_id
        }
      ]
    }
    prod = {
      tgw_route_table_id = module.secondary_region.tgw_route_table_id["prod"]
      routes = [
        {
          destination_cidr_blocks = var.aws_ip_address_plan.primary_region.prod.cidr_blocks
          tgw_attachment_id       = module.tgw_peering_primary_to_secondary.tgw_attachment_id
        },
        {
          destination_cidr_blocks = var.aws_ip_address_plan.primary_region.shared.cidr_blocks
          tgw_attachment_id       = module.tgw_peering_primary_to_secondary.tgw_attachment_id
        }
      ]
    }
    stage = {
      tgw_route_table_id = module.secondary_region.tgw_route_table_id["stage"]
      routes = [
        {
          destination_cidr_blocks = var.aws_ip_address_plan.primary_region.stage.cidr_blocks
          tgw_attachment_id       = module.tgw_peering_primary_to_secondary.tgw_attachment_id
        },
        {
          destination_cidr_blocks = var.aws_ip_address_plan.primary_region.shared.cidr_blocks
          tgw_attachment_id       = module.tgw_peering_primary_to_secondary.tgw_attachment_id
        }
      ]
    }
    dev = {
      tgw_route_table_id = module.secondary_region.tgw_route_table_id["dev"]
      routes = [
        {
          destination_cidr_blocks = var.aws_ip_address_plan.primary_region.dev.cidr_blocks
          tgw_attachment_id       = module.tgw_peering_primary_to_secondary.tgw_attachment_id
        },
        {
          destination_cidr_blocks = var.aws_ip_address_plan.primary_region.shared.cidr_blocks
          tgw_attachment_id       = module.tgw_peering_primary_to_secondary.tgw_attachment_id
        }
      ]
    }
  }
}
