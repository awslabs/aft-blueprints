# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_ec2_transit_gateway_route_table" "this" {
  for_each = toset(var.route_tables)

  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = merge(
    { "Name" = "tgw-rtb-${each.key}" },
    var.tags
  )
}

resource "aws_ssm_parameter" "tgw_route_table" {
  # checkov:skip=CKV_AWS_337:This SSM parameter is not a SecureString and there is no need to encrypt it using KMS
  for_each = toset(var.route_tables)

  name        = "/org/core/network/tgw-route-table/${each.key}"
  type        = "String"
  description = "Transit Gateway route table ${each.key} Id"
  value       = aws_ec2_transit_gateway_route_table.this[each.key].id
}
