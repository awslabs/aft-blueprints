# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

variable "region_cidr_blocks" {
  description = "List with IPAM region CIDR Blocks"
  type        = list(string)
}

variable "availability_zones" {
  description = <<-EOF
  "Map of availability zones allowed to be used in this region."
  Example:
    ```
    availability_zones = {
      az1 = "us-east-1a"
      az2 = "us-east-1b"
      az3 = "us-east-1c"
    }
    ```
EOF
  type        = map(string)
  validation {
    condition = alltrue(
      [for az in keys(var.availability_zones) : true if contains(["az1", "az2", "az3", "az4"], az)]
    )
    error_message = "You must specify a list with valid availability zones allowed in this region, such as az1, az2, az3 and az4."
  }
}

variable "vpc_endpoint_services" {
  description = <<-EOF
  "List with the VPC endpoint services to be centralized in the network account."
  Example:
    ```
    vpc_endpoint_services = [
      "ec2",
      "ec2messages",
      "ssm",
      "ssmmessages"
    ]
    ```
EOF
  type        = list(string)
  default     = []
}

variable "tgw_amazon_side_asn" {
  description = <<-EOF
  The Autonomous System Number (ASN) for the Amazon side of the TGW in this region."
  The range is from 64512 to 65534 for 16-bit ASNs.
  The range is from 4200000000 to 4294967294 for 32-bit ASNs."
EOF
  type        = number
  validation {
    condition     = (var.tgw_amazon_side_asn >= 64512 && var.tgw_amazon_side_asn <= 65534) || (var.tgw_amazon_side_asn >= 4200000000 && var.tgw_amazon_side_asn <= 4294967294)
    error_message = "Enter a valid 16-bit or 32-bit ASN."
  }
  default = "64512"
}

variable "private_cidr_blocks" {
  description = "List with private CIDR Blocks (RFC1918)"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

variable "ipam_pools" {
  description = "Map with IPAM pool information."
  type        = map(any)
  default     = {}
}

variable "vpn_cgw_ip_address" {
  type        = string
  description = "The Internet-routable IP address for the customer gateway's outside interface. The address must be static."
  validation {
    condition     = can(regex("^(\\d{1,3}\\.){3}\\d{1,3}$", var.vpn_cgw_ip_address))
    error_message = "Must be a valid IPv4 IP address."
  }
}

variable "vpn_cgw_bgp_asn" {
  type        = number
  description = "For devices that support BGP, the customer gateway's BGP ASN. Default value of 65000 specifies static routing. Value shoud be between 64512 and 65534."
  # BGP private ASN values per https://docs.aws.amazon.com/vpn/latest/s2svpn/cgw-options.html
  default = 65000
  validation {
    condition     = var.vpn_cgw_bgp_asn >= 64512 && var.vpn_cgw_bgp_asn <= 65534
    error_message = "Value shoud be between 64512 and 65534."
  }
}

variable "vpn_static_routes_only" {
  description = "Whether the VPN connection uses static routes exclusively."
  type        = bool
  default     = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
