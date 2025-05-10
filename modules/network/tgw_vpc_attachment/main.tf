# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  subnet_ids                                      = var.subnet_ids
  transit_gateway_id                              = local.tgw_id
  vpc_id                                          = var.vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  lifecycle {
    ignore_changes = [
      transit_gateway_default_route_table_association,
      transit_gateway_default_route_table_propagation
    ]
  }
  tags = { Name = local.attachment_name }
}

resource "aws_ec2_tag" "vpc_attachment" {
  provider = aws.network

  resource_id = aws_ec2_transit_gateway_vpc_attachment.this.id
  key         = "Name"
  value       = local.attachment_name
}

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  provider = aws.network

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = local.tgw_rt_association_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = local.tgw_rt_propagation_ids
  provider = aws.network

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = each.value
}
