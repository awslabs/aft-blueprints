# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw" {
  count = var.use_tgw_attachment_automation ? 0 : 1

  subnet_ids                                      = [for sub in local.subnets : aws_subnet.subnets[sub.key].id if sub.tgw_attachment == true]
  transit_gateway_id                              = var.tgw_id
  vpc_id                                          = aws_vpc.this.id
  appliance_mode_support                          = "enable"
  dns_support                                     = "enable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = merge(
    { "Name" = "${var.account_id}-tgw-attach-${local.vpc_name}" },
    var.tags
  )
}

resource "aws_ec2_tag" "vpc_attachment" {
  count    = var.use_tgw_attachment_automation ? 0 : 1
  provider = aws.network

  resource_id = aws_ec2_transit_gateway_vpc_attachment.tgw[0].id
  key         = "Name"
  value       = "${var.account_id}-tgw-attach-${local.vpc_name}"
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw" {
  count    = var.use_tgw_attachment_automation ? 0 : 1
  provider = aws.network

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw[0].id
  transit_gateway_route_table_id = var.tgw_rt_association_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = var.use_tgw_attachment_automation ? {} : var.tgw_rt_propagation_ids
  provider = aws.network

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw[0].id
  transit_gateway_route_table_id = each.value
}
