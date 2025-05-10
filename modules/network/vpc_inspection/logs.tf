# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

module "local_vpc_flow_logs" {
  source = "../flow_logs"
  count  = var.enable_vpc_flow_logs ? 1 : 0

  resource_type = "vpc"
  resource_id   = aws_vpc.vpc.id
  resource_name = "${local.vpc_name}-${var.region_name}"
  account_id    = var.account_id
  tags          = var.tags
}

module "central_vpc_flow_logs" {
  source = "../flow_logs"
  count  = var.enable_central_vpc_flow_logs ? 1 : 0

  resource_type             = "vpc"
  resource_id               = aws_vpc.vpc.id
  resource_name             = "${local.vpc_name}-${var.region_name}"
  destination_type          = "s3"
  s3_destination_bucket_arn = var.central_vpc_flow_logs_destination_arn
  tags                      = var.tags
}
