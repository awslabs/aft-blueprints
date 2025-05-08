# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

variable "gateway_name" {
  description = "Name for the Direct Connect gateway"
  type        = string
  default     = "aws-dx-gateway"
}

variable "bgp_asn" {
  description = "BGP ASN for the Direct Connect gateway (Amazon side)"
  type        = number
  default     = 64512
}
