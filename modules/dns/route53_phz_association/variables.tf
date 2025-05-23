# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

variable "phz_id" {
  type        = string
  description = "The Private Hosted Zone ID"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID (required is associate_to_local_vpc==true)"
  default     = null
}

variable "vpc_region" {
  type        = string
  description = "The VPC region"
}

variable "associate_to_local_vpc" {
  type        = bool
  description = "Associate local VPC with the Private Hosted Zone (requires vpc_id variable)"
  default     = true
}

variable "associate_to_central_dns_vpc" {
  type        = bool
  description = "Associate central DNS VPC with the Private Hosted Zone"
  default     = true
}
