# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

module "phz" {
  source = "../../../common/modules/dns/route53_phz"
  count  = var.phz_name == null ? 0 : 1

  name               = var.phz_name
  create_test_record = true
  vpc_id             = module.vpc[0].vpc_id
  tags               = var.tags
}

module "phz_association_1" {
  source = "../../../common/modules/dns/route53_phz_association"
  count  = var.phz_name == null ? 0 : 1
  providers = {
    aws.dns = aws.dns1
  }

  phz_id = module.phz[0].zone_id
}
