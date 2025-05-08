# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

variable "name" {
  type        = string
  description = "Name of the IAM Analyzer"
  default     = "iam-analyzer"
}

variable "type" {
  type        = string
  description = "Type of zone of trust for the IAM Analyzer"
  default     = "ACCOUNT"
  validation {
    condition     = contains(["ACCOUNT", "ORGANIZATION", "ACCOUNT_UNUSED_ACCESS", "ORGANIZATION_UNUSED_ACCESS"], var.type)
    error_message = "Valid values: ACCOUNT | ORGANIZATION | ACCOUNT_UNUSED_ACCESS | ORGANIZATION_UNUSED_ACCESS"
  }
}

variable "unused_access_age" {
  type        = string
  description = "Specify a number of days for the tracking the period. Applied to ACCOUNT_UNUSED_ACCESS and ORGANIZATION_UNUSED_ACCESS access analysis only."
  default     = 90
}

variable "tags" {
  type    = map(string)
  default = {}
}
