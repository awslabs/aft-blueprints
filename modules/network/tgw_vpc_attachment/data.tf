# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

data "aws_caller_identity" "network" {
  provider = aws.network
}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "tgw_id" {
  provider = aws.network

  name = "/org/core/network/tgw-id"
}

data "aws_ssm_parameter" "rt_association" {
  provider = aws.network

  name = "/org/core/network/tgw-route-table/${var.route_table_name}"
}

data "aws_ssm_parameter" "propagation_rules" {
  provider = aws.network

  name = "/org/core/network/tgw-propagation-rules"
}

data "aws_ssm_parameter" "rt_propagations" {
  for_each = local.tgw_rt_propagation_rule
  provider = aws.network

  name = "/org/core/network/tgw-route-table/${each.value}"
}
