# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

variable "account_id" {
  type        = string
  description = "Account ID"
  default     = ""
  validation {
    condition     = can(regex("(?:^\\d{12}$|)", var.account_id))
    error_message = "The account_id value must be 12 digits."
  }
}

variable "vpc_id" {
  description = "VPC Id"
  type        = string
}

variable "vpc_name" {
  description = "VPC Name"
  type        = string
  default     = "vpc"
}

variable "subnet_ids" {
  description = "List of subnet id to be attached to Transit Gateway"
  type        = list(string)
}

variable "route_table_name" {
  description = "Transit Gateway route table name to be associated with the vpc attachment."
  type        = string
  default     = ""
}
