# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "central_vpc_flow_logs_s3_bucket_arn" {
  count    = var.enable_central_vpc_flow_logs ? 1 : 0
  provider = aws.network

  name = "/org/core/network/vpc-flow-logs/s3-bucket-arn"
}
