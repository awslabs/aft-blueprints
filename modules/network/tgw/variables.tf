# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

variable "region_name" {
  type        = string
  description = "TGW region name. You can use a long or short name. (This value will form the resource name)"
  default     = ""
}

variable "amazon_side_asn" {
  type    = string
  default = "64512"
}

variable "route_tables" {
  type    = list(string)
  default = []
}

variable "propagation_rules" {
  type    = map(list(string))
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
