# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_route53_zone_association" "phz" {
  count = var.associate_to_local_vpc == true ? 1 : 0

  vpc_id     = var.vpc_id
  vpc_region = var.vpc_region
  zone_id    = var.phz_id
}

resource "aws_route53_vpc_association_authorization" "authorization" {
  for_each = var.associate_to_central_dns_vpc ? { for vpc in data.aws_vpcs.this[0].ids : vpc => vpc } : {}

  vpc_id     = each.value
  zone_id    = var.phz_id
  vpc_region = var.vpc_region
}

resource "aws_route53_zone_association" "association" {
  for_each   = var.associate_to_central_dns_vpc ? { for vpc in data.aws_vpcs.this[0].ids : vpc => vpc } : {}
  depends_on = [aws_route53_vpc_association_authorization.authorization]
  provider   = aws.dns

  vpc_id     = each.value
  zone_id    = var.phz_id
  vpc_region = var.vpc_region
}
