# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

output "transit_gateway_id" {
  description = "Transit Gateway Id"
  value       = aws_ec2_transit_gateway.this.id
}

output "route_table_id" {
  description = "Map of Route Table Ids"
  value       = { for rt in toset(var.route_tables) : rt => aws_ec2_transit_gateway_route_table.this[rt].id }
}


