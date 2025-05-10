# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

resource "random_string" "id" {
  count = var.identifier == "" ? 1 : 0

  length    = 4
  special   = false
  upper     = false
  lower     = true
  min_lower = 2
  numeric   = true
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  ipv4_ipam_pool_id    = var.vpc_cidr == null ? var.ipam_pool_id : null
  ipv4_netmask_length  = var.vpc_cidr == null ? 24 : null
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    { "Name" = "${local.vpc_name}-${var.region_name}" },
    var.tags
  )
  lifecycle {
    # Added to prevent VPC from being recreated after changes to the IPAM module
    ignore_changes = [ipv4_ipam_pool_id]
  }
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  route                  = []
  tags = merge(
    { "Name" = "${local.vpc_name}-default-rtb" },
    var.tags
  )
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
  lifecycle {
    create_before_destroy = true
  }
  tags = merge(
    { "Name" = "${local.vpc_name}-default-sgp" },
    var.tags
  )
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.vpc.default_network_acl_id
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  lifecycle {
    ignore_changes = [subnet_ids]
  }
  tags = merge(
    { "Name" = "${local.vpc_name}-default-acl" },
    var.tags
  )
}
