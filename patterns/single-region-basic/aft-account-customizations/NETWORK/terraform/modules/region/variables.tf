# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

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

variable "tags" {
  type    = map(string)
  default = {}
}
