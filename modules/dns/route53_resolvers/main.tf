# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

###########################################################
##############        Inbound Resolver       ##############
###########################################################
resource "aws_security_group" "inbound" {
  name        = "sgp-${var.route53_resolver_name}-inbound"
  description = "Allow DNS Traffic in to Route53 Inbound Resolver Endpoint"
  vpc_id      = var.vpc_id
  ingress {
    description = "RFC1918 communication"
    from_port   = 53
    to_port     = 53
    protocol    = "UDP"
    cidr_blocks = var.rfc1918_cidr
  }
  egress {
    description = "Allow egress for all destinations"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(
    { "Name" = "sgp-${var.route53_resolver_name}-inbound" },
    var.tags
  )
  lifecycle {
    # Necessary if changing 'name' or 'name_prefix' properties.
    create_before_destroy = true
  }
}

resource "aws_route53_resolver_endpoint" "inbound" {
  name               = "${var.route53_resolver_name}-inbound"
  direction          = "INBOUND"
  security_group_ids = [aws_security_group.inbound.id]
  dynamic "ip_address" {
    for_each = var.route53_resolver_subnet_ids
    content {
      subnet_id = ip_address.value
    }
  }
  tags = merge(
    { "Name" = "${var.route53_resolver_name}-inbound" },
    var.tags
  )
}


###########################################################
##############       Outbound Resolver       ##############
###########################################################
resource "aws_security_group" "outbound" {
  name        = "sgp-${var.route53_resolver_name}-outbound"
  description = "Allow DNS Traffic in to Route53 Outbound Resolver Endpoint"
  vpc_id      = var.vpc_id
  egress {
    description = "Allow egress for all destinations"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(
    { "Name" = "sgp-${var.route53_resolver_name}-outbound" },
    var.tags
  )
  lifecycle {
    # Necessary if changing 'name' or 'name_prefix' properties.
    create_before_destroy = true
  }
}

resource "aws_route53_resolver_endpoint" "outbound" {
  name               = "${var.route53_resolver_name}-outbound"
  direction          = "OUTBOUND"
  security_group_ids = [aws_security_group.outbound.id]
  dynamic "ip_address" {
    for_each = var.route53_resolver_subnet_ids
    content {
      subnet_id = ip_address.value
    }
  }
  tags = merge(
    { "Name" = "${var.route53_resolver_name}-outbound" },
    var.tags
  )
}


###########################################################
##############         Resolver Rules        ##############
###########################################################
resource "aws_route53_resolver_rule" "forward" {
  for_each   = { for rule in local.rules : rule.domain_name => rule }
  depends_on = [aws_route53_resolver_endpoint.inbound]

  domain_name          = each.value.domain_name
  name                 = each.value.rule_name
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound.id

  dynamic "target_ip" {
    for_each = toset(each.value.target_ip)
    content {
      ip = target_ip.value
    }
  }

  tags = merge(
    { Name = each.value.rule_name },
    var.tags
  )
}

resource "aws_route53_resolver_rule_association" "forward" {
  for_each = { for rule in local.rules : rule.domain_name => rule if rule.associate_to_vpc }

  resolver_rule_id = aws_route53_resolver_rule.forward[each.value.domain_name].id
  vpc_id           = var.vpc_id
}

resource "aws_ram_resource_share" "this" {
  name                      = "r53-resolver-rules-${data.aws_region.current.name}"
  allow_external_principals = false
  tags                      = var.tags
}

resource "aws_ram_principal_association" "this" {
  principal          = data.aws_organizations_organization.org.arn
  resource_share_arn = aws_ram_resource_share.this.arn
}

resource "aws_ram_resource_association" "this" {
  for_each = { for rule in local.rules : rule.domain_name => rule }

  resource_arn       = aws_route53_resolver_rule.forward[each.value.domain_name].arn
  resource_share_arn = aws_ram_resource_share.this.arn
}