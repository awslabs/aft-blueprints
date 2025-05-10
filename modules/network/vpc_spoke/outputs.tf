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

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = [for sub in aws_subnet.private : sub.id]
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = [for sub in aws_subnet.public : sub.id]
}

output "data_subnets" {
  description = "List of IDs of private subnets"
  value       = [for sub in aws_subnet.data : sub.id]
}

output "tgw_attachment_id" {
  description = "The ID of the transit gateway attachment"
  value       = var.use_tgw_attachment_automation ? module.tgw_attachment_automation[0].transit_gateway_attachment_id : aws_ec2_transit_gateway_vpc_attachment.tgw[0].id
}
