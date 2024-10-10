# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

module "tgw_vpc_attachment" {
  source = "../tgw_vpc_attachment"
  providers = {
    aws.network = aws.network
  }

  vpc_id                  = aws_vpc.this.id
  vpc_name                = local.vpc_name
  subnet_ids              = [for sub in local.subnets : aws_subnet.subnets[sub.key].id if sub.tgw_attachment == true]
  tgw_id                  = var.tgw_id
  tgw_rt_association_name = var.environment
  tgw_rt_association_id   = var.tgw_rt_association_id
  tgw_rt_propagations     = var.tgw_rt_propagations
}

module "vpce" {
  source = "../vpce"

  vpc_id   = aws_vpc.this.id
  vpc_name = local.vpc_name
  vpc_cidr = aws_vpc.this.cidr_block
  interface_endpoints = {
    subnet_ids = [for sub in local.subnets : aws_subnet.subnets[sub.key].id if sub.vpc_endpoint == true]
    services   = var.interface_endpoints
  }
  gateway_endpoints = {
    route_table_ids = [for rt in aws_route_table.subnets : rt.id]
    services        = var.gateway_endpoints
  }
}

module "route53_rules_association" {
  source = "../../dns/route53_rules_association"
  count  = var.associate_dns_rules ? 1 : 0

  vpc_id = aws_vpc.this.id
}
