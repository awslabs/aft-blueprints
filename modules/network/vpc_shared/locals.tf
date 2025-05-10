# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

locals {
  id          = var.identifier == "" ? random_string.id[0].result : var.identifier
  region      = var.region_name == "" ? data.aws_region.current.name : var.region_name
  account_id  = var.account_id == "" ? data.aws_caller_identity.current[0].account_id : var.account_id
  vpc_name    = "vpc-${var.environment}-${local.id}"
  cidrsubnets = cidrsubnets(aws_vpc.this.cidr_block, 1, 2, 2)
  vpc_size    = local.vpc_size_map[var.vpc_size]
  vpc_size_map = {
    small  = 24
    medium = 23
    large  = 22
    xlarge = 21
  }

  azs = length(var.az_set) > 0 ? {
    for i, az in keys(var.az_set) : az => {
      index = i
      id    = az
      name  = var.az_set[az]
    }
    } : {
    for i, az in var.availability_zones : az => {
      index = i
      id    = az
      name  = data.aws_availability_zone.current[az].name
    }
  }

  subnets = flatten(
    [for sub in var.subnets :
      [for key, az in local.azs :
        {
          key            = "${sub.name}_${key}"
          name           = sub.name
          newbits        = sub.newbits
          index          = sum([sub.index, az.index])
          tgw_attachment = lookup(sub, "tgw_attachment", false)
          vpc_endpoint   = lookup(sub, "vpc_endpoint", false)
          tags           = lookup(sub, "tags", {})
          az_id          = az.id
          az_name        = az.name
        }
      ]
    ]
  )
}
