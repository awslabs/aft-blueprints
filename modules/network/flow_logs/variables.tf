# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

variable "resource_type" {
  type        = string
  description = "The AWS resource type to capture flow logs traffic."
  validation {
    condition     = contains(["vpc", "subnet", "eni", "transit_gateway", "transit_gateway_attachment"], var.resource_type)
    error_message = "The resource type is invalid, it should be: vpc, subnet, eni, transit_gateway or transit_gateway_attachment."
  }
}

variable "resource_id" {
  type        = string
  description = "The AWS resource ID to capture flow logs traffic."
}

variable "resource_name" {
  type        = string
  description = "The AWS resource name to capture flow logs traffic."
}


variable "traffic_type" {
  type        = string
  description = "The traffic type to capture: ACCEPT, REJECT or ALL."
  default     = "ALL"
  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.traffic_type)
    error_message = "The traffic type is invalid, it should be: ACCEPT, REJECT or ALL."
  }
}

variable "destination_type" {
  type        = string
  description = "The destination type to capture: cloud-watch-logs or s3. This module doesn't support kinesis-data-firehose."
  default     = "cloud-watch-logs"
  validation {
    condition     = contains(["cloud-watch-logs", "s3"], var.destination_type)
    error_message = "The destination type is invalid, it should be: cloud-watch-logs or s3."
  }
}

variable "log_format" {
  type        = string
  description = "The fields to include in the flow log record. Accepted format example: '$${interface-id} $${srcaddr} $${srcport} $${dstaddr} $${dstport} $${protocol}'"
  default     = null
}

variable "max_aggregation_interval" {
  type        = number
  description = "The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Expressed in seconds (e.g 60 = 1 minute)"
  default     = 60
}

variable "cloudwatch_log_group" {
  type        = map(string)
  description = <<-EOF
  CloudWatch Log group configuration.
  Example:
    ```
    cloudwatch_log_group = {
      name              = my-log-group
      retention_in_days = 30
      kms_key_id        = null
      skip_destroy      = false
      log_group_class   = "STANDARD"
    }
    ```
EOF
  default     = {}
}

variable "s3_bucket_arn" {
  type        = string
  description = "The ARN of the S3 bucket to export flow logs to."
  default     = null
}

variable "s3_destination_options" {
  type = object({
    file_format                = string # plain-text or parquet
    hive_compatible_partitions = bool   # true or false
    per_hour_partition         = bool   # true or false
  })
  description = "The options for the flow log destination: file_format, hive_compatible_partitions and per_hour_partition. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log#destination_options"
  default = {
    file_format                = "parquet"
    hive_compatible_partitions = true
    per_hour_partition         = true
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources."
  default     = {}
}
