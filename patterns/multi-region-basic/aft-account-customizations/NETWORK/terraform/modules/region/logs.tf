# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0


resource "aws_ssm_parameter" "central_vpc_flow_logs_s3_bucket" {
  # checkov:skip=CKV_AWS_337:This SSM parameter is not a SecureString and there is no need to encrypt it using KMS
  name        = "/org/core/network/vpc-flow-logs/s3-bucket-arn"
  type        = "String"
  description = "S3 bucket ARN for centralized VPC Flow Logs "
  value       = data.aws_ssm_parameter.central_vpc_flow_logs_s3_bucket_arn.value
  tags        = var.tags
}
