# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

variable "bucket_name" {
  type        = string
  description = "S3 Bucket Name"
}

variable "aws_organization_service_principals" {
  type        = list(string)
  description = "Inform the AWS Organization service principals to access the S3 Bucket. If not set, no organization level access will be applied."
  default     = []
}

variable "aws_kms_customer_managed_key" {
  type        = string
  description = "Inform the AWS KMS Customer managed key ID to use to encrypt the S3 Bucket. If not set, the S3 Bucket will be encrypted with the AWS managed key."
  default     = ""
}

variable "expiration_days" {
  type        = number
  description = "Define the days to expire S3 objects."
  default     = 360
}

variable "transition_rules" {
  type = list(object({
    days          = number
    storage_class = string
  }))
  description = "List of transition rules for the S3 bucket lifecycle configuration."
  default = [{
    days          = 0
    storage_class = "INTELLIGENT_TIERING"
  }]
}

variable "noncurrent_version_expiration_days" {
  type        = number
  description = "Define the days to expire non-current S3 objects."
  default     = 7
}

variable "noncurrent_version_transition_rules" {
  type = list(object({
    noncurrent_days = number
    storage_class   = string
  }))
  description = "List of transition rules for non-current object versions for S3 bucket lifecycle configuration."
  default = [{
    noncurrent_days = 0
    storage_class   = "INTELLIGENT_TIERING"
  }]
}

variable "abort_incomplete_multipart_upload_days" {
  type        = number
  description = "Number of days after which Amazon S3 aborts an incomplete multipart upload."
  default     = 1
}

variable "tags" {
  type        = map(any)
  description = "Tags to apply to the S3 Bucket"
  default     = {}
}
