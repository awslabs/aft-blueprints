# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

data "aws_region" "current" {}

data "aws_ssm_parameter" "central_vpc_flow_logs_s3_bucket_arn" {
  provider = aws.log-archive

  name = "/org/core/central-logs/vpc-flow-logs"
}
