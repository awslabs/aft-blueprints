# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_flow_log" "this" {

  traffic_type                  = var.traffic_type
  log_destination_type          = var.destination_type
  deliver_cross_account_role    = null
  iam_role_arn                  = var.destination_type == "s3" ? null : aws_iam_role.cloudwatch[0].arn
  log_destination               = var.destination_type == "s3" ? var.s3_destination_bucket_arn : aws_cloudwatch_log_group.cloudwatch[0].arn
  subnet_id                     = var.resource_type == "subnet" ? var.resource_id : null
  transit_gateway_id            = var.resource_type == "transit_gateway" ? var.resource_id : null
  transit_gateway_attachment_id = var.resource_type == "transit_gateway_attachment" ? var.resource_id : null
  vpc_id                        = var.resource_type == "vpc" ? var.resource_id : null
  eni_id                        = var.resource_type == "eni" ? var.resource_id : null
  log_format                    = var.log_format
  max_aggregation_interval      = var.max_aggregation_interval
  dynamic "destination_options" {
    for_each = var.destination_type == "s3" ? [1] : []
    content {
      file_format                = var.s3_destination_options.file_format
      hive_compatible_partitions = var.s3_destination_options.hive_compatible_partitions
      per_hour_partition         = var.s3_destination_options.per_hour_partition
    }
  }
  tags = merge(
    var.tags,
    { Name = "flow-logs-to-${var.destination_type}" }
  )
}


###########################################################
##############      CloudWatch Flow Logs     ##############
###########################################################

resource "aws_cloudwatch_log_group" "cloudwatch" {
  #checkov:skip=CKV_AWS_338: The retention period is defined using a variable. In this case, the logs refer to network traffic and 1 year of retention will increase the cost.
  # checkov:skip=CKV_AWS_158:Log group data is always encrypted in CloudWatch Logs. By default, CloudWatch Logs uses server-side encryption for the log data at rest.
  count = var.destination_type == "cloud-watch-logs" ? 1 : 0

  name              = lookup(var.cloudwatch_log_group, "name", "/aws/vpc-flow-logs/${var.resource_name}")
  retention_in_days = lookup(var.cloudwatch_log_group, "retention_in_days", 1)
  kms_key_id        = lookup(var.cloudwatch_log_group, "kms_key_id", null)
  skip_destroy      = lookup(var.cloudwatch_log_group, "skip_destroy", false)
  log_group_class   = lookup(var.cloudwatch_log_group, "log_group_class", "STANDARD")
  tags              = var.tags
}

resource "aws_iam_role" "cloudwatch" {
  count = var.destination_type == "cloud-watch-logs" ? 1 : 0

  name = "flow-logs-cw-${var.resource_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "VpcFlowLogsAssumeRole"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Effect = "Allow"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = [var.account_id]
          }
        }
      }
    ]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "cloudwatch" {
  count = var.destination_type == "cloud-watch-logs" ? 1 : 0

  name = "CloudWatchAccessPolicy"
  role = aws_iam_role.cloudwatch[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["logs:DescribeLogGroups"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = aws_cloudwatch_log_group.cloudwatch[0].arn
      },
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.cloudwatch[0].arn}:*"
      }
    ]
  })
}
