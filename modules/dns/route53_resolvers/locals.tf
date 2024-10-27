# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

locals {
  rules = {
    for k, v in var.rules : k => {
      rule_name        = replace(v.domain_name, ".", "-")
      domain_name      = v.domain_name
      target_ip        = length(v.external_dns_ips) > 0 ? v.external_dns_ips : aws_route53_resolver_endpoint.inbound.ip_address[*].ip
      associate_to_vpc = length(v.external_dns_ips) > 0 ? true : false
    }
  }
}
