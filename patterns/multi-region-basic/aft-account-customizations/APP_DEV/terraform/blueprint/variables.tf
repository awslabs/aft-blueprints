# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

variable "vpc" {
  type        = map(any)
  description = "VPC parameters"
  default     = null
}

variable "create_phz" {
  type        = bool
  description = "Whether create and associate the PHZ or associate it only."
  default     = false
}

variable "phz_name" {
  type        = string
  description = "Route 53 Private Hosted Zone name to create and/or associate to the centralized DNS VPC. [inform it if you are creating the PHZ]"
  default     = null
}

variable "phz_id" {
  type        = string
  description = "Route 53 Private Hosted Zone Id to associate to the centralized DNS VPC. [use it when you are NOT creating the PHZ]"
  default     = null
}

variable "tags" {
  type        = map(any)
  description = "Define additional tags to be used by resources."
  default     = {}
}
