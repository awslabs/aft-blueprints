# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

## +-------
## | SNS - Topic for pipeline approvals' notification
## +---------------------------------

resource "aws_sns_topic" "approval_notification" {
  name              = "${var.project_name}-approval-notification"
  kms_master_key_id = aws_kms_key.pipeline_key.key_id
  tags              = var.tags
}

resource "aws_sns_topic_policy" "pipeline" {
  arn = aws_sns_topic.approval_notification.arn

  policy = jsonencode({
    "Version" : "2008-10-17",
    "Id" : "__default_policy_ID",
    "Statement" : [
      {
        "Sid" : "__default_statement_ID",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : [
          "SNS:GetTopicAttributes",
          "SNS:SetTopicAttributes",
          "SNS:AddPermission",
          "SNS:RemovePermission",
          "SNS:DeleteTopic",
          "SNS:Subscribe",
          "SNS:ListSubscriptionsByTopic",
          "SNS:Publish"
        ],
        "Resource" : "${aws_sns_topic.approval_notification.arn}",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceOwner" : "${data.aws_caller_identity.current.account_id}"
          }
        }
      },
      {
        "Sid" : "codepipeline",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${aws_iam_role.codepipeline_role.arn}"
        },
        "Action" : [
          "SNS:Publish"
        ],
        "Resource" : "${aws_sns_topic.approval_notification.arn}"
      }
    ]
  })
}