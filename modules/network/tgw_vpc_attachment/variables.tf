# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

variable "vpc_id" {
  description = "VPC Id"
  type        = string
}

variable "vpc_name" {
  description = "VPC Name"
  type        = string
  default     = "vpc"
}

variable "subnet_ids" {
  description = "List of subnet id to be attached to Transit Gateway"
  type        = list(string)
}

variable "tgw_id" {
  description = "Transit Gateway Id"
  type        = string
  default     = null
}

variable "use_tgw_id_parameter" {
  description = "Use the Transit Gateway Id from the parameter store. Overrides tgw_id variable."
  type        = bool
  default     = true
}

variable "tgw_rt_association_name" {
  description = "Transit Gateway route table name to be associated with the vpc attachment."
  type        = string
  default     = ""
}

variable "tgw_rt_association_id" {
  description = "Transit Gateway route table Id to be associated with the vpc attachment."
  type        = string
  default     = null
}

variable "tgw_rt_propagations" {
  description = "Transit Gateway route table to propagations. k => v, name => route_table_id"
  type        = map(string)
  default     = {}
}

variable "use_propagation_rules" {
  description = "Use the Transit Gateway route table propagation rules, based on the associated route table."
  type        = bool
  default     = true
}
