# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

variable "enable_s3_bpa" {
  type        = bool
  description = "Block S3 public access at account level"
  default     = true
}

variable "enable_ami_bpa" {
  type        = bool
  description = "Block public sharing of AMI at account level"
  default     = true
}

variable "enforce_ebs_encryption" {
  type        = bool
  description = "Enforce EBS encryption at account level"
  default     = true
}

variable "default_ebs_kms_key" {
  type        = string
  description = "Default EBS KMS Key"
  default     = ""
}

variable "enforce_imdsv2" {
  type        = bool
  description = "Enforce IMDSv2 at account level"
  default     = true
}
