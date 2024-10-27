# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

data "aws_region" "current" {}

data "aws_caller_identity" "network" {
  provider = aws.network
}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "tgw_id" {
  count    = var.use_tgw_id_parameter ? 1 : 0
  provider = aws.network

  name = "/org/core/network/tgw-id"
}

data "aws_ssm_parameter" "rt_association" {
  count    = local.use_association_parameter ? 1 : 0
  provider = aws.network

  name = "/org/core/network/tgw-route-table/${var.tgw_rt_association_name}"
}

data "aws_ssm_parameter" "propagation_rules" {
  count    = var.use_propagation_rules ? 1 : 0
  provider = aws.network

  name = "/org/core/network/tgw-propagation-rules"
}

data "aws_ssm_parameter" "rt_propagations" {
  for_each = toset(var.use_propagation_rules ? jsondecode(data.aws_ssm_parameter.propagation_rules[0].insecure_value)[var.tgw_rt_association_name] : [])
  provider = aws.network

  name = "/org/core/network/tgw-route-table/${each.value}"
}
