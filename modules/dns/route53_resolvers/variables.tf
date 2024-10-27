# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

variable "vpc_id" {
  type        = string
  description = "The VPC to associate with resolver endpoint."
  default     = null
}

variable "route53_resolver_name" {
  type        = string
  description = "The name for your resolver endpoint. The module will append '-inbound' or '-outbound' to the name."
  default     = "resolver-endpoint"
}

variable "route53_resolver_subnet_ids" {
  type        = list(string)
  description = "List of subnet ids to be used by resolver to create a interface endpoint."
  default     = null
}

variable "rfc1918_cidr" {
  type        = list(string)
  description = "List of private address cidrs."
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

variable "rules" {
  type = map(object(
    {
      domain_name      = string
      external_dns_ips = optional(list(string), [])
    }
  ))
  description = "The domain_name and external_dns_ips (if applicable) for resolver rule to forward DNS requests."
}

variable "tags" {
  type        = map(any)
  description = "Define additional tags to be used by resources."
  default     = {}
}
