# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

module "phz" {
  source = "../../../common/modules/dns/route53_phz"
  count  = var.create_phz && var.phz_name != null ? 1 : 0

  name               = var.phz_name
  vpc_id             = module.vpc[0].vpc_id
  create_test_record = true
  tags               = var.tags
}

module "phz_association" {
  source = "../../../common/modules/dns/route53_phz_association"
  count  = var.phz_name == null ? 0 : 1
  providers = {
    aws.dns = aws.network
  }

  phz_id                       = var.phz_id == null ? module.phz[0].zone_id : var.phz_id
  vpc_id                       = var.create_phz ? null : try(module.vpc[0].vpc_id, null)
  vpc_region                   = data.aws_region.current.name
  associate_to_local_vpc       = var.create_phz ? false : var.vpc == null ? false : true
  associate_to_central_dns_vpc = true
}
