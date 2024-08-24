# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

locals {
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
  dns_resolver_rules = [
    {
      domain_name = "on.aws"
    }
  ]
}