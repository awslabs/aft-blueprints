# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

module "primary_region" {
  source = "./blueprint"

  providers = {
    aws         = aws.primary
    aws.network = aws.network-primary
  }

  phz_name = local.phz_name
  vpc      = local.vpc
  tags     = local.tags
}
