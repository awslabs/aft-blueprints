# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

module "phz" {
  source = "../../../common/modules/dns/route53_phz"
  count  = var.phz_name == null ? 0 : 1

  name               = var.phz_name
  vpc_id             = module.vpc[0].vpc_id
  create_test_record = true
  tags               = var.tags
}
