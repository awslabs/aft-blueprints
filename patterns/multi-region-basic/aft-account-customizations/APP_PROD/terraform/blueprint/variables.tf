# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

variable "vpc" {
  type        = map(any)
  description = "VPC paramenters"
  default     = null
}

variable "phz_name" {
  type        = string
  description = "Route 53 Private Hosted Zone name."
  default     = null
}

variable "backup_account_id" {
  type        = string
  description = "Central AWS Backup account id."
}

variable "create_backup_role" {
  type        = bool
  description = "Whether create backup role."
  default     = false
}

variable "tags" {
  type        = map(any)
  description = "Define additional tags to be used by resources."
  default     = {}
}
