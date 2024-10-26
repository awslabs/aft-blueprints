# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

variable "identifier" {
  description = "VPC identifier. If not entered, a random id will be generated."
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name. Will be used to define ipam pool and tgw route tables configuration."
  type        = string
  validation {
    condition     = contains(["shared"], var.environment)
    error_message = "The environment value is invalid, it should be 'shared'."
  }
  default = "shared"
}

variable "vpc_cidr" {
  description = "The IPv4 CIDR block for the VPC. [required if vpc_size is not informed]"
  type        = string
  default     = null
}

variable "vpc_size" {
  description = "VPC netmask size to be allocated in IPAM [required if vpc_cidr is not informed]"
  type        = string
  default     = "medium"
  validation {
    condition     = contains(["small", "medium", "large", "xlarge"], var.vpc_size)
    error_message = "The vpc size value is invalid, it should be 'small', 'medium', 'large' or 'xlarge'."
  }
}

variable "ipam_pool_id" {
  type        = string
  description = "IPAM pool id to get the VPc CIDR [optional, if don't want to use 'environment' to get the pool]"
  default     = null
}

variable "availability_zones" {
  description = "List of availability zones defined in the network account"
  type        = list(string)
  validation {
    condition = alltrue(
      [for az in var.availability_zones : true if contains(["az1", "az2", "az3", "az4"], az)]
    )
    error_message = "You must specify a list with valid availability zones allowed in this region, such as az1, az2, az3 and az4."
  }
  default = []
}

variable "subnets" {
  description = "The number of subnets per AZ"
  type = list(object(
    {
      name           = string
      newbits        = number
      index          = number
      tgw_attachment = optional(bool)
      vpc_endpoint   = optional(bool)
      tags           = optional(map(string))
    }
  ))
}

variable "tgw_id" {
  description = "Transit Gateway Id"
  type        = string
  default     = ""
}

variable "tgw_rt_association_id" {
  description = "Transit Gateway route table Id that should receive the VPC attachment association"
  type        = string
  default     = ""
}

variable "tgw_rt_propagations" {
  description = "List with Transit Gateway route table that should receive the VPC attachment propagation"
  type        = list(string)
  default     = []
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_vpc_flow_logs" {
  description = "Should be true to enable vpc flow logs to a local cloudwatch log group."
  type        = bool
  default     = true
}

variable "enable_central_vpc_flow_logs" {
  description = "Should be true to enable centralized vpc flow logs to S3 bucket."
  type        = bool
  default     = false
}

variable "associate_dns_rules" {
  description = "Should be true to associate shared Route 53 DNS rules"
  type        = bool
  default     = true
}

variable "interface_endpoints" {
  description = "A list of interface endpoints"
  type        = list(string)
  default     = []
}

variable "gateway_endpoints" {
  description = "A list of interface endpoints"
  type        = list(string)
  default     = []
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags for all resources within the VPC"
  type        = map(string)
  default     = {}
}
