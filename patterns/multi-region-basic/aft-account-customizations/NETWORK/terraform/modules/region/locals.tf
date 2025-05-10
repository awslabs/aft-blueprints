# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

locals {
  tgw_route_tables = [
    "security",
    "shared",
    "prod",
    "stage",
    "dev"
  ]
  tgw_propagation_rules = {
    shared = ["security", "shared", "prod", "stage", "dev"]
    prod   = ["security", "shared", "prod"]
    stage  = ["security", "shared", "stage"]
    dev    = ["security", "shared", "dev"]
  }
  dns_resolver_rules = {
    phz = {
      domain_name = "on.aws"
    }
    vpce = {
      domain_name = "${var.region_name}.amazonaws.com"
    }
  }
}
