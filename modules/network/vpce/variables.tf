# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_name" {
  type    = string
  default = "vpc"
}

variable "allowed_cidr" {
  description = "Additional CIDRs to be added in the interface endpoints security group."
  type        = list(string)
  default     = []
}

variable "interface_endpoints" {
  description = "A list of subnets and interface endpoints"
  type = object({
    subnet_ids = list(string)
    services   = list(string)
  })
  default = {
    subnet_ids = []
    services   = []
  }
}

variable "gateway_endpoints" {
  description = "A list of route tables and gateway endpoints"
  type = object({
    route_table_ids = list(string)
    services        = list(string)
  })
  default = {
    route_table_ids = []
    services        = []
  }
  validation {
    condition = (
      length(var.gateway_endpoints.services) == 0 ||
      alltrue([for service in var.gateway_endpoints.services : contains(["s3", "dynamodb"], service)])
    )
    error_message = "The value of services is invalid, it must be one of the follwing: s3 or dynamodb."
  }
}
