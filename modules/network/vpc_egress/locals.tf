# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

locals {
  id          = var.identifier == "" ? random_string.id[0].result : var.identifier
  vpc_name    = "vpc-${var.environment}-${local.id}"
  cidrsubnets = cidrsubnets(aws_vpc.vpc.cidr_block, 2, 2, 2, 2)

  azs = {
    for i, az in keys(var.az_set) : az => {
      index = i
      id    = az
      name  = var.az_set[az]
    }
  }
}
