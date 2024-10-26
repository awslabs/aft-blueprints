# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

########################################
#######   AFT Core Parameters    #######
########################################
resource "aws_ssm_parameter" "account_id" {
  # checkov:skip=CKV_AWS_337:This SSM parameter is not a SecureString and there is no need to encrypt it using KMS
  provider = aws.aft-management

  name        = "/org/core/accounts/ct-log-archive"
  type        = "String"
  description = "Control Tower Log Archive Account Id"
  value       = data.aws_caller_identity.current.account_id
  tags        = local.tags
}


########################################
#######       VPC Flow Logs      #######
########################################

module "primary_vpc_flow_logs" {
  source = "../../common/modules/storage/s3_bucket_for_logs"
  providers = {
    aws = aws.primary
  }

  bucket_name                         = "aws-central-vpc-flow-logs-${data.aws_caller_identity.current.account_id}-${data.aws_region.primary.name}"
  aws_organization_service_principals = ["delivery.logs.amazonaws.com"]
  tags                                = local.tags
}

resource "aws_ssm_parameter" "primary_vpc_flow_logs_s3_bucket_name" {
  # checkov:skip=CKV_AWS_337:This SSM parameter is not a SecureString and there is no need to encrypt it using KMS
  provider = aws.primary

  name        = "/org/core/central-logs/vpc-flow-logs"
  type        = "String"
  description = "S3 bucket ARN for centralized VPC Flow Logs"
  value       = module.primary_vpc_flow_logs.s3_bucket_arn
  tags        = local.tags
}

module "secondary_vpc_flow_logs" {
  source = "../../common/modules/storage/s3_bucket_for_logs"
  providers = {
    aws = aws.secondary
  }

  bucket_name                         = "aws-central-vpc-flow-logs-${data.aws_caller_identity.current.account_id}-${data.aws_region.secondary.name}"
  aws_organization_service_principals = ["delivery.logs.amazonaws.com"]
  tags                                = local.tags
}

resource "aws_ssm_parameter" "secondary_vpc_flow_logs_s3_bucket_name" {
  # checkov:skip=CKV_AWS_337:This SSM parameter is not a SecureString and there is no need to encrypt it using KMS
  provider = aws.secondary

  name        = "/org/core/central-logs/vpc-flow-logs"
  type        = "String"
  description = "S3 bucket ARN for centralized VPC Flow Logs"
  value       = module.secondary_vpc_flow_logs.s3_bucket_arn
  tags        = local.tags
}
