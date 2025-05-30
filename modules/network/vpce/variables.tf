# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

variable "vpc_id" {
  description = "The ID of the VPC in which the endpoint will be used."
  type        = string
}

variable "vpc_region" {
  description = "The region of the VPC in which the endpoint will be used."
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC in which the endpoint will be used."
  type        = string
  default     = "vpc"
}

variable "vpc_cidr" {
  description = "The CIDR of the VPC in which the endpoint will be used. This CIDR will be added to the interface endpoints security group created by the module (when security_group_id is not informed)."
  type        = string
  default     = null
}

variable "allowed_cidr" {
  description = "Additional CIDRs to be added in the interface endpoints security group created by the module (when security_group_id is not informed)."
  type        = list(string)
  default     = []
}

variable "security_group_id" {
  description = "The ID of the security group to be added in the interface endpoints."
  type        = string
  default     = null
}

variable "private_dns_enabled" {
  description = "Whether or not to enable private DNS."
  type        = bool
  default     = true
}

variable "gateway_endpoints" {
  description = "A list of route tables and gateway endpoints"
  type = object({
    route_table_ids = list(string)
    services        = list(string)
  })
  default = {
    route_table_ids = []
    services        = []
  }
  validation {
    condition = (
      length(var.gateway_endpoints.services) == 0 ||
      alltrue([for service in var.gateway_endpoints.services : contains(["s3", "s3express", "dynamodb"], service)])
    )
    error_message = "The value of services is invalid, it must be one of the following: s3 or dynamodb."
  }
}

variable "interface_endpoints" {
  description = "A list of subnet IDs and interface endpoint service names. For service names use com.amazonaws.<region>.<service> format, or just <service> (e.g. com.amazonaws.us-east-1.ssm or ssm)."
  type = object({
    subnet_ids = list(string)
    services   = list(string)
  })
  default = {
    subnet_ids = []
    services   = []
  }
}

variable "policies" {
  description = "A map with endpoint service name (key) and IAM resource policy JSON (value) to be applied to endpoint. For service names use com.amazonaws.<region>.<service> format, or just <service> (e.g. com.amazonaws.us-east-1.ssm or ssm)."
  type        = map(any)
  default     = {}
}

variable "tags" {
  description = "Tags to be applied to all resources."
  type        = map(string)
  default     = {}
}
