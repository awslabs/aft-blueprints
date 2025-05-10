# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

variable "account_id" {
  type        = string
  description = "Account ID"
  validation {
    condition     = can(regex("(?:^\\d{12}$|)", var.account_id))
    error_message = "The account_id value must be 12 digits."
  }
}

variable "connection_name" {
  type        = string
  description = "The name of the VPN connection"
}

variable "customer_gateway_id" {
  type        = string
  description = "The Customer gateway ID"
}

variable "transit_gateway_id" {
  type        = string
  description = "The Transit Gateway ID"
}

variable "static_routes_only" {
  description = "Whether the VPN connection uses static routes exclusively."
  type        = bool
  default     = false
}

variable "local_ipv4_network_cidr" {
  description = "The IPv4 CIDR on the customer gateway (on-premises) side of the VPN connection."
  type        = string
  default     = "0.0.0.0/0"
}

variable "remote_ipv4_network_cidr" {
  description = "The IPv4 CIDR on the customer gateway (on-premises) side of the VPN connection."
  type        = string
  default     = "0.0.0.0/0"
}

variable "tgw_rt_association" {
  description = "Transit Gateway route table ID to be associated with the VPN attachment."
  type        = string
}

variable "tgw_rt_propagations" {
  description = "Transit Gateway route table IDs to propagate routes based VPN BGP configuration."
  type        = map(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}
