# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

data "aws_region" "current" {}

data "aws_availability_zone" "current" {
  for_each = { for az in var.availability_zones : az => data.aws_ssm_parameter.azs[az].value }
  filter {
    name   = "zone-id"
    values = [each.value]
  }
}

data "aws_ssm_parameter" "azs" {
  for_each = toset(var.availability_zones)
  provider = aws.network

  name = "/org/core/network/availability-zones/${each.value}"
}

data "aws_ssm_parameter" "central_vpc_flow_logs_s3_bucket_arn" {
  count    = var.enable_central_vpc_flow_logs ? 1 : 0
  provider = aws.network

  name = "/org/core/network/vpc-flow-logs/s3-bucket-arn"
}

data "aws_vpc_ipam_pool" "vpc" {
  count = var.vpc_cidr == null ? 1 : 0

  filter {
    name   = "description"
    values = ["${var.environment}-ipam-pool"]
  }
  filter {
    name   = "locale"
    values = [local.region]
  }
}
