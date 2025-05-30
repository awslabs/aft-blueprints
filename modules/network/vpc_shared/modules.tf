# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

module "tgw_attachment_automation" {
  source = "../tgw_vpc_attachment"
  count  = var.use_tgw_attachment_automation ? 1 : 0
  providers = {
    aws.network = aws.network
  }

  account_id       = var.account_id
  vpc_id           = aws_vpc.this.id
  vpc_name         = local.vpc_name
  subnet_ids       = [for sub in local.subnets : aws_subnet.subnets[sub.key].id if sub.tgw_attachment == true]
  route_table_name = var.environment
}

module "vpce" {
  source = "../vpce"

  vpc_id     = aws_vpc.this.id
  vpc_region = data.aws_region.current.name
  vpc_name   = local.vpc_name
  vpc_cidr   = aws_vpc.this.cidr_block
  interface_endpoints = {
    subnet_ids = [for sub in local.subnets : aws_subnet.subnets[sub.key].id if sub.vpc_endpoint == true]
    services   = var.interface_endpoints
  }
  gateway_endpoints = {
    route_table_ids = toset(values(aws_route_table.subnets)[*].id)
    services        = var.gateway_endpoints
  }
  policies = var.endpoint_policies
}

module "route53_rules_association" {
  source = "../../dns/route53_rules_association"
  count  = var.associate_dns_rules ? 1 : 0

  vpc_id = aws_vpc.this.id
}

module "local_vpc_flow_logs" {
  source = "../flow_logs"
  count  = var.enable_vpc_flow_logs ? 1 : 0

  resource_type = "vpc"
  resource_id   = aws_vpc.this.id
  resource_name = "${local.vpc_name}-${local.region}"
  account_id    = local.account_id
  tags          = var.tags
}

module "central_vpc_flow_logs" {
  source = "../flow_logs"
  count  = var.enable_central_vpc_flow_logs ? 1 : 0

  resource_type             = "vpc"
  resource_id               = aws_vpc.this.id
  resource_name             = "${local.vpc_name}-${local.region}"
  destination_type          = "s3"
  s3_destination_bucket_arn = var.central_vpc_flow_logs_destination_arn == "" ? data.aws_ssm_parameter.central_vpc_flow_logs_s3_bucket_arn[0].value : var.central_vpc_flow_logs_destination_arn
  tags                      = var.tags
}
