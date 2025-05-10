# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_ec2_transit_gateway" "this" {
  #checkov:skip=CKV_AWS_331:The VPC attachment will be managed using terraform modules
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  amazon_side_asn                 = var.amazon_side_asn
  description                     = "Regional Transit Gateway"
  tags = merge(
    { "Name" = "tgw-${var.region_name}" },
    var.tags
  )
  timeouts {
    create = "30m"
    update = "30m"
  }
}

resource "aws_ram_resource_share" "tgw" {
  name                      = "tgw-${var.region_name}"
  allow_external_principals = false
  tags = {
    "Name" = "tgw-${var.region_name}"
  }
}

resource "aws_ram_resource_association" "tgw" {
  resource_arn       = aws_ec2_transit_gateway.this.arn
  resource_share_arn = aws_ram_resource_share.tgw.arn
}

resource "aws_ram_principal_association" "tgw" {
  principal          = data.aws_organizations_organization.this.arn
  resource_share_arn = aws_ram_resource_share.tgw.arn
}

resource "aws_ssm_parameter" "propagation_rules" {
  # checkov:skip=CKV_AWS_337:This SSM parameter is not a SecureString and there is no need to encrypt it using KMS
  name        = "/org/core/network/tgw-propagation-rules"
  type        = "String"
  description = "Transit Gateway route table propagation rules"
  value       = jsonencode(var.propagation_rules)
}

resource "aws_ssm_parameter" "tgw_id" {
  # checkov:skip=CKV_AWS_337:This SSM parameter is not a SecureString and there is no need to encrypt it using KMS
  name        = "/org/core/network/tgw-id"
  type        = "String"
  description = "Transit Gateway Id"
  value       = aws_ec2_transit_gateway.this.id
}
