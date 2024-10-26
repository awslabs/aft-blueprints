# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

locals {
  region = data.aws_region.current.name
  tgw_route_tables = [
    "shared",
    "prod",
    "stage",
    "dev",
    "egress"
  ]
  tgw_propagation_rules = {
    shared = ["prod", "stage", "dev", "shared", "egress"]
    prod   = ["prod", "shared", "egress"]
    stage  = ["stage", "shared", "egress"]
    dev    = ["dev", "shared", "egress"]
  }
}
