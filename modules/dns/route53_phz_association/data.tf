# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

data "aws_vpcs" "this" {
  count = var.associate_to_central_dns_vpc ? 1 : 0

  provider = aws.dns

  filter {
    name   = "tag-key"
    values = ["dns-service"]
  }
}
