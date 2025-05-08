# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

variable "vpc" {
  type        = map(any)
  description = "VPC parameters"
  default     = null
}

variable "phz_name" {
  type        = string
  description = "Route 53 Private Hosted Zone name."
  default     = null
}

variable "tags" {
  type        = map(any)
  description = "Define additional tags to be used by resources."
  default     = {}
}
