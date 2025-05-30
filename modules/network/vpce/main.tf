# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_security_group" "endpoints" {
  count = local.create_security_group ? 1 : 0

  name_prefix = "${var.vpc_name}-endpoints-sgp-"
  description = "Allow endpoints communication"
  vpc_id      = var.vpc_id

  tags = merge(
    { "Name" = "${var.vpc_name}-endpoints-sgp" },
    var.tags
  )

  lifecycle {
    # Necessary if changing 'name' or 'name_prefix' properties.
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpc" {
  count = local.create_security_group ? 1 : 0

  security_group_id = aws_security_group.endpoints[0].id
  description       = "Allow VPC ingress traffic"
  cidr_ipv4         = var.vpc_cidr
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "endpoints" {
  for_each = local.create_security_group ? toset(var.allowed_cidr) : []

  security_group_id = aws_security_group.endpoints[0].id
  description       = "Allow additional ingress traffic"
  cidr_ipv4         = each.value
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "endpoints" {
  count = local.create_security_group ? 1 : 0

  security_group_id = aws_security_group.endpoints[0].id
  description       = "Allow ALL egress traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_endpoint" "interface" {
  for_each = toset(var.interface_endpoints.services)

  vpc_id              = var.vpc_id
  service_name        = length(try(regex("\\..*\\.", each.value), [])) > 0 ? each.value : "com.amazonaws.${var.vpc_region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = local.create_security_group ? [aws_security_group.endpoints[0].id] : [var.security_group_id]
  subnet_ids          = var.interface_endpoints.subnet_ids
  private_dns_enabled = var.private_dns_enabled
  policy              = lookup(var.policies, each.value, null)
  tags = merge(
    { "Name" = "${var.vpc_name}-${replace(each.value, ".", "-")}-endpoint" },
    var.tags
  )
  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}

resource "aws_vpc_endpoint" "gateway" {
  for_each = toset(var.gateway_endpoints.services)

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.vpc_region}.${each.value}"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.gateway_endpoints.route_table_ids
  tags = merge(
    { "Name" = "${var.vpc_name}-${each.value}-gw-endpoint" },
    var.tags
  )
  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}
