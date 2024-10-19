# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

module "vpc" {
  source = "../../../common/modules/network/vpc_spoke"
  count  = var.vpc == null ? 0 : 1
  providers = {
    aws.network = aws.network
  }

  identifier            = lookup(var.vpc, "identifier", "")
  environment           = lookup(var.vpc, "environment", null)
  vpc_size              = lookup(var.vpc, "vpc_size", null)
  create_public_subnets = lookup(var.vpc, "create_public_subnets", false)
  create_data_subnets   = lookup(var.vpc, "create_data_subnets", false)
  availability_zones    = ["az1", "az2"]
  enable_flow_log       = false
  gateway_endpoints     = ["s3"]
  tags                  = var.tags
}
