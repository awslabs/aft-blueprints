# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

data "aws_region" "current" {}

data "aws_route53_zone" "phz" {
  count      = var.phz_name == null ? 0 : 1
  depends_on = [module.phz]

  name         = var.phz_name
  private_zone = true
}
