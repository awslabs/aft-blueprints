# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

locals {
  id            = var.identifier == "" ? random_string.id[0].result : var.identifier
  vpc_name      = "vpc-${var.environment}-${local.id}"
  firewall_name = "${var.identifier}-network-firewall"
  cidrsubnets   = cidrsubnets(aws_vpc.vpc.cidr_block, 2, 2, 2, 2)

  azs = {
    for i, az in keys(var.az_set) : az => {
      index = i
      id    = az
      name  = var.az_set[az]
    }
  }

  internal_tgw_routes = flatten([for id, az in local.azs : [
    for cidr in var.tgw_routes : {
      id      = id
      az_name = az.name
      cidr    = cidr
    }]
  ])

  nfw_endpoints = flatten([
    for nfwe in aws_networkfirewall_firewall.nfw.firewall_status[0].sync_states[*] : {
      az_name = nfwe.availability_zone
      id      = nfwe.attachment[0].endpoint_id
    }
  ])
}
