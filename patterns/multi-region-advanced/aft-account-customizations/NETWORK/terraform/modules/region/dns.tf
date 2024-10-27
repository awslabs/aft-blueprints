# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

module "route53_resolvers" {
  source = "../../../../common/modules/dns/route53_resolvers"

  vpc_id                      = module.vpc_endpoints.vpc_id
  route53_resolver_subnet_ids = module.vpc_endpoints.subnets["private"]
  rules                       = local.dns_resolver_rules
  tags                        = var.tags
}
