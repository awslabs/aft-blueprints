# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw" {
  depends_on = [aws_subnet.tgw]

  subnet_ids                                      = [for subnet in aws_subnet.tgw : subnet.id]
  transit_gateway_id                              = var.transit_gateway_id
  vpc_id                                          = aws_vpc.vpc.id
  appliance_mode_support                          = "enable"
  dns_support                                     = "enable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = merge(
    { "Name" = "${var.account_id}-tgw-attach-${local.vpc_name}" },
    var.tags
  )
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw.id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
}
