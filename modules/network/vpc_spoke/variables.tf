# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

variable "identifier" {
  description = "VPC identifier. If not entered, a random id will be generated."
  type        = string
  default     = ""
}

variable "region_name" {
  type        = string
  description = "VPC region name. You can use a long or short name. (This value will form the resource name)"
  default     = ""
}

variable "environment" {
  description = "Environment name. Will be used to define ipam pool and tgw route tables configuration."
  type        = string
  validation {
    condition     = contains(["prod", "stage", "dev"], var.environment)
    error_message = "The environment value is invalid, it should be 'prod' or 'dev'."
  }
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

variable "account_id" {
  type        = string
  description = "Account ID"
  default     = ""
  validation {
    condition     = can(regex("(?:^\\d{12}$|)", var.account_id))
    error_message = "The account_id value must be 12 digits."
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

variable "create_nat_gateway" {
  description = "Should be true to create a NAT Gateway the VPC"
  type        = bool
  default     = false
}

variable "create_public_subnets" {
  description = "Should be true to create public subnets and IGw in the VPC"
  type        = bool
  default     = false
}

variable "create_data_subnets" {
  description = "Should be true to create public subnets and IGw in the VPC"
  type        = bool
  default     = false
}

variable "use_tgw_attachment_automation" {
  description = "Use the Transit Gateway attachment automation."
  type        = bool
  default     = true
}

variable "tgw_id" {
  description = "Transit Gateway Id. (only if use_tgw_attachment_automation==false)"
  type        = string
  default     = null
}

variable "tgw_rt_association_id" {
  description = "Transit Gateway route table Id that should receive the VPC attachment association. (only if use_tgw_attachment_automation==false)"
  type        = string
  default     = null
}

variable "tgw_rt_propagation_ids" {
  description = "Transit Gateway route table to propagations. k => v, name => route_table_id. (only if use_tgw_attachment_automation==false)"
  type        = map(string)
  default     = {}
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

variable "central_vpc_flow_logs_destination_arn" {
  type        = string
  description = "The ARN of the resource destination to export VPC flow logs to."
  default     = null
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

variable "endpoint_policies" {
  description = "A map of endpoint policies"
  type        = map(any)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for private subnets"
  type        = map(string)
  default     = {}
}

variable "data_subnet_tags" {
  description = "Additional tags data subnets"
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags for public subnets"
  type        = map(string)
  default     = {}
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
