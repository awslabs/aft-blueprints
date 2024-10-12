# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

variable "aws_ip_address_plan" {
  description = <<-EOF
  "Object with IP address plan which defines the CIDR blocks to be used in AWS regions."
  Example:
    ```
    aws_ip_address_plan = {
      global_cidr_blocks = ["10.10.0.0/16","10.20.0.0/16"]
      primary_region = {
        cidr_blocks = ["10.10.0.0/16"]
        shared = {
          cidr_blocks = ["10.10.0.0/18"]
        }
        prod = {
          cidr_blocks = ["10.10.64.0/18"]
        }
        stage = {
          cidr_blocks = ["10.10.128.0/18"]
        }
        dev = {
          cidr_blocks = ["10.10.192.0/18"]
        }
      }
      secondary_region = {
        cidr_blocks = ["10.20.0.0/16"]
        shared = {
          cidr_blocks = ["10.20.0.0/18"]
        }
        prod = {
          cidr_blocks = ["10.20.64.0/18"]
        }
        stage = {
          cidr_blocks = ["10.20.128.0/18"]
        }
        dev = {
          cidr_blocks = ["10.20.192.0/18"]
        }
      }
    }
    ```
EOF
  type = object({
    global_cidr_blocks = list(string)
    primary_region = object({
      cidr_blocks = list(string)
      shared = object({
        cidr_blocks = list(string)
      })
      prod = object({
        cidr_blocks = list(string)
      })
      stage = object({
        cidr_blocks = list(string)
      })
      dev = object({
        cidr_blocks = list(string)
      })
    })
    secondary_region = optional(object({
      cidr_blocks = list(string)
      shared = object({
        cidr_blocks = list(string)
      })
      prod = object({
        cidr_blocks = list(string)
      })
      stage = object({
        cidr_blocks = list(string)
      })
      dev = object({
        cidr_blocks = list(string)
      })
    }))
  })
}

variable "aws_availability_zones" {
  description = <<-EOF
  "Map of availability zones allowed to be used in this region."
  Example:
    ```
    aws_availability_zones = {
      primary_region = {
        az1 = "us-east-1a"
        az2 = "us-east-1b"
      }
      secondary_region = {
        az1 = "us-west-2a"
        az2 = "us-west-2b"
      }
    }
    ```
EOF
  type        = map(any)
  validation {
    condition = alltrue(
      flatten([for region in var.aws_availability_zones : [
        for az in keys(region) : true if contains(["az1", "az2", "az3", "az4"], az)
      ]])
    )
    error_message = "You must specify a list with valid availability zones allowed in this region, such as az1, az2, az3 and az4."
  }
}

variable "aws_vpc_endpoint_services" {
  description = <<-EOF
  "List with the VPC endpoint services to be centralized in the network account."
  Example:
    ```
  [
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
