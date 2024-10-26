# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

module "tgw_vpc_attachment" {
  source = "../tgw_vpc_attachment"
  providers = {
    aws.network = aws.network
  }

  vpc_id                  = aws_vpc.this.id
  vpc_name                = local.vpc_name
  subnet_ids              = [for sub in aws_subnet.private : sub.id]
  tgw_rt_association_name = var.environment
}

module "vpce" {
  source = "../vpce"

  vpc_id   = aws_vpc.this.id
  vpc_name = local.vpc_name
  vpc_cidr = aws_vpc.this.cidr_block
  interface_endpoints = {
    subnet_ids = [for sub in aws_subnet.private : sub.id]
    services   = var.interface_endpoints
  }
  gateway_endpoints = {
    route_table_ids = toset(concat(values(aws_route_table.private)[*].id, try([aws_route_table.public.id], [])))
    services        = var.gateway_endpoints
  }
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
  tags          = var.tags
}

module "central_vpc_flow_logs" {
  source = "../flow_logs"
  count  = var.enable_central_vpc_flow_logs ? 1 : 0

  resource_type    = "vpc"
  resource_id      = aws_vpc.this.id
  resource_name    = "${local.vpc_name}-${local.region}"
  destination_type = "s3"
  s3_bucket_arn    = data.aws_ssm_parameter.central_vpc_flow_logs_s3_bucket_arn[0].value
  tags             = var.tags
}
