# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

locals {
  tgw_route_tables = [
    "shared",
    "prod",
    "stage",
    "dev",
    "inspection",
    "gateway"
  ]
  tgw_propagation_rules = {
    shared = ["shared", "prod", "stage", "dev", "inspection"]
    prod   = ["shared", "inspection"]
    stage  = ["shared", "inspection"]
    dev    = ["shared", "inspection"]
  }
  dns_resolver_rules = [
    {
      domain_name = "on.aws"
    },
    {
      domain_name = "${var.region}.amazonaws.com"
    }
  ]
}
