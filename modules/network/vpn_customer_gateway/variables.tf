# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

variable "customer_gateway_name" {
  type        = string
  description = "The name of the customer gateway."
}

variable "customer_gateway_ip_address" {
  type        = string
  description = "The Internet-routable IP address for the customer gateway's outside interface. The address must be static."
  validation {
    condition     = can(regex("^(\\d{1,3}\\.){3}\\d{1,3}$", var.customer_gateway_ip_address))
    error_message = "Must be a valid IPv4 IP address."
  }
}

variable "customer_gateway_bgp_asn" {
  type        = number
  description = "For devices that support BGP, the customer gateway's BGP ASN. Default value of 65000 specifies static routing. Value should be between 64512 and 65534."
  default     = 65000
  # BGP private ASN values per https://docs.aws.amazon.com/vpn/latest/s2svpn/cgw-options.html
  validation {
    condition     = var.customer_gateway_bgp_asn >= 64512 && var.customer_gateway_bgp_asn <= 65534
    error_message = "Value should be between 64512 and 65534."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
