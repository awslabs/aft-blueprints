# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

module "local_vpc_flow_logs" {
  source = "../flow_logs"
  count  = var.enable_vpc_flow_logs ? 1 : 0

  resource_type = "vpc"
  resource_id   = aws_vpc.vpc.id
  resource_name = "${local.vpc_name}-${local.region}"
  tags          = var.tags
}

module "central_vpc_flow_logs" {
  source = "../flow_logs"
  count  = var.enable_central_vpc_flow_logs ? 1 : 0

  resource_type    = "vpc"
  resource_id      = aws_vpc.vpc.id
  resource_name    = "${local.vpc_name}-${local.region}"
  destination_type = "s3"
  s3_bucket_arn    = data.aws_ssm_parameter.central_vpc_flow_logs_s3_bucket_arn[0].value
  tags             = var.tags
}
