# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
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
    condition     = contains(["shared"], var.environment)
    error_message = "The environment value is invalid, it should be 'shared'."
  }
  default = "shared"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR (minimum size /24) [required if ipam_pool_id is not informed]"
  default     = null
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
  description = "IPAM pool id to get the VPc CIDR [required if vpc_cidr is not informed]"
  default     = null
}

variable "az_set" {
  description = <<-EOF
  "Map of availability zones. It overrides the variable availability_zones"
  Example:
    ```
    az_set = {
      az1 = "us-east-1a"
      az2 = "us-east-1b"
      az3 = "us-east-1c"
    }
    ```
EOF
  type        = map(string)
  validation {
    condition = alltrue(
      [for az in keys(var.az_set) : true if contains(["az1", "az2", "az3", "az4"], az)]
    )
    error_message = "You must specify a list with valid availability zones allowed in this region, such as az1, az2, az3 and az4."
  }
  default = {}
}


variable "transit_gateway_id" {
  type        = string
  description = "Transit Gateway Id"
}

variable "transit_gateway_route_table_id" {
  type        = string
  description = "Transit Gateway Route Table Id to associate the VPC attachment"
}

variable "enable_egress" {
  type        = bool
  default     = true
  description = "It creates public resources to allow egress traffic"
}

variable "tgw_routes" {
  type        = list(string)
  description = "Private network CIDR to be routed to the Transit Gateway"
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

variable "network_firewall_config" {
  type = object(
    {
      home_net                           = optional(list(string))
      stateless_default_actions          = optional(string)
      stateless_fragment_default_actions = optional(string)
      flow_log                           = optional(bool)
      alert_log                          = optional(bool)
    }
  )
  default = {
    home_net                           = null
    stateless_default_actions          = "aws:forward_to_sfe"
    stateless_fragment_default_actions = "aws:forward_to_sfe"
    flow_log                           = true
    alert_log                          = true
  }
  description = <<-EOF
  Map of network firewall configurations. 
  Available options:
    - `home_net`                = Used to expand the local network definition beyond the CIDR range of the VPC where you deploy Network Firewall
    - `stateless_default_actions`           = Set of actions to take on a packet if it does not match any of the stateless rules in the policy.
                                              You must specify one of the standard actions including: aws:drop, aws:pass or aws:forward_to_sfe.
    - `stateless_fragment_default_actions`  = Set of actions to take on a fragmented packet if it does not match any of the stateless rules in the policy.
                                              You must specify one of the standard actions including: aws:drop, aws:pass or aws:forward_to_sfe.
    - `flow_log`                            = Indicates whether the network firewall flow logs should be activated
    - `alert_log`                           = Indicates whether the network firewall alert logs should be activated
EOF
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

variable "vpc_tags" {
  description = "Tags for all resources within the VPC"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags for all resources within the VPC"
  type        = map(string)
  default     = {}
}
