# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_cloudwatch_event_bus" "pipeline" {
  count = var.account_lifecycle_events_source != "None" ? 1 : 0

  name = "${var.solution_name}-event-bus"
}

resource "aws_cloudwatch_event_permission" "pipeline" {
  count = var.account_lifecycle_events_source != "None" ? 1 : 0

  event_bus_name = aws_cloudwatch_event_bus.pipeline[0].name
  principal      = local.event_rule_account_id
  statement_id   = "SourceEventAccountAccess"
}

resource "aws_cloudwatch_event_rule" "pipeline" {
  count = var.account_lifecycle_events_source != "None" ? 1 : 0

  name           = "${var.solution_name}-controltower-events"
  description    = "Capture Control Tower events to start the permission set pipeline"
  event_bus_name = aws_cloudwatch_event_bus.pipeline[0].name
  event_pattern = jsonencode({
    "account" : [local.event_rule_account_id]
    }
  )
}

resource "aws_cloudwatch_event_target" "pipeline" {
  count = var.account_lifecycle_events_source != "None" ? 1 : 0

  event_bus_name = aws_cloudwatch_event_bus.pipeline[0].name
  rule           = aws_cloudwatch_event_rule.pipeline[0].name
  role_arn       = aws_iam_role.start_pipeline.arn
  arn            = aws_codepipeline.this.arn
}

resource "aws_cloudwatch_event_rule" "ct_events" {
  count    = var.account_lifecycle_events_source == "CT" ? 1 : 0
  provider = aws.event-source-account

  name        = "${var.solution_name}-ct-events"
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
  count    = var.account_lifecycle_events_source == "CT" ? 1 : 0
  provider = aws.event-source-account

  rule     = aws_cloudwatch_event_rule.ct_events[0].name
  role_arn = aws_iam_role.ct_events[0].arn
  arn      = aws_cloudwatch_event_bus.pipeline[0].arn
}

resource "aws_iam_role" "ct_events" {
  count    = var.account_lifecycle_events_source == "CT" ? 1 : 0
  provider = aws.event-source-account

  name_prefix        = "${var.solution_name}-ct-events"
  assume_role_policy = file("${path.module}/assets/trust-policies/events.json")
}

resource "aws_iam_role_policy" "ct_events" {
  count    = var.account_lifecycle_events_source == "CT" ? 1 : 0
  provider = aws.event-source-account

  name = "PutEventsPermission"
  role = aws_iam_role.ct_events[0].id
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["events:PutEvents"]
          Effect   = "Allow"
          Resource = aws_cloudwatch_event_bus.pipeline[0].arn
        }
      ]
    }
  )
}
