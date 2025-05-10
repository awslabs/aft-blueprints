# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

output "identifier" {
  description = "Identifier string"
  value       = local.id
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "subnets" {
  description = "Map of subnet IDs grouped by name"
  value       = { for sub in var.subnets : sub.name => [for subnet in local.subnets : aws_subnet.subnets[subnet.key].id if subnet.name == sub.name] }
}

output "route_tables" {
  description = "Map of route table IDs grouped by name"
  value       = { for sub in var.subnets : sub.name => [for subnet in local.subnets : aws_route_table.subnets[subnet.key].id if subnet.name == sub.name] }
}

output "tgw_attachment_id" {
  description = "The ID of the transit gateway attachment"
  value       = var.use_tgw_attachment_automation ? module.tgw_attachment_automation[0].transit_gateway_attachment_id : aws_ec2_transit_gateway_vpc_attachment.tgw[0].id
}
