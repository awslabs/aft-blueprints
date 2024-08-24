# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_cloudwatch_event_bus" "pipeline" {
  name = "${var.app_name}-event-bus"
}

resource "aws_cloudwatch_event_permission" "pipeline" {
  event_bus_name = aws_cloudwatch_event_bus.pipeline.name
  principal      = local.event_rule_account_id
  statement_id   = "SourceEventAccountAccess"
}

resource "aws_cloudwatch_event_rule" "pipeline" {
  name           = "${var.app_name}-controltower-events"
  description    = "Capture Control Tower events to start the permission set pipeline"
  event_bus_name = aws_cloudwatch_event_bus.pipeline.name
  event_pattern = jsonencode({
    "account" : [local.event_rule_account_id]
    }
  )
}

resource "aws_cloudwatch_event_target" "pipeline" {
  event_bus_name = aws_cloudwatch_event_bus.pipeline.name
  rule           = aws_cloudwatch_event_rule.pipeline.name
  role_arn       = aws_iam_role.main.arn
  arn            = aws_codepipeline.main.arn
}

resource "aws_cloudwatch_event_rule" "ct_events" {
  count    = var.use_control_tower_events ? 1 : 0
  provider = aws.org-management

  name        = "${var.app_name}-ct-events"
  description = "Capture Control Tower events to send to the permission set pipeline event bus"
  event_pattern = jsonencode(
    {
      "source" : ["aws.controltower"],
      "detail-type" : ["AWS Service Event via CloudTrail"],
      "detail" : {
        "eventName" : ["CreateManagedAccount", "UpdateManagedAccount"]
      }
    }
  )
}

resource "aws_cloudwatch_event_target" "ct_events" {
  count    = var.use_control_tower_events ? 1 : 0
  provider = aws.org-management

  rule     = aws_cloudwatch_event_rule.ct_events[0].name
  role_arn = aws_iam_role.ct_events[0].arn
  arn      = aws_cloudwatch_event_bus.pipeline.arn
}

resource "aws_iam_role" "ct_events" {
  count    = var.use_control_tower_events ? 1 : 0
  provider = aws.org-management

  name_prefix        = "${var.app_name}-ct-events"
  assume_role_policy = file("${path.module}/assets/trust-policies/events.json")
  inline_policy {
    name = "inline_policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["events:PutEvents"]
          Effect   = "Allow"
          Resource = aws_cloudwatch_event_bus.pipeline.arn
        }
      ]
    })
  }
}