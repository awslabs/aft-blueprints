# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

locals {
  region = data.aws_region.current.name
  tgw_route_tables = [
    "shared",
    "prod",
    "stage",
    "dev",
    "egress",
    "gateway"
  ]
  tgw_propagation_rules = {
    shared = ["shared", "prod", "stage", "dev", "egress", "gateway"]
    prod   = ["prod", "shared", "egress", "gateway"]
    stage  = ["stage", "shared", "egress", "gateway"]
    dev    = ["dev", "shared", "egress", "gateway"]
  }
  dns_resolver_rules = {
    phz = {
      domain_name = "on.aws"
    }
    vpce = {
      domain_name = "${local.region}.amazonaws.com"
    }
  }
}
