# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

data "aws_ssoadmin_instances" "sso" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_organizations_organization" "org" {
  count = var.account_lifecycle_events_source == "CT" ? 1 : 0
}

data "local_file" "buildspec" {
  filename = "${path.module}/assets/buildspecs/buildspec.yml"
}

data "archive_file" "aft_new_account_event_forwarder" {
  count       = var.account_lifecycle_events_source == "AFT" ? 1 : 0
  type        = "zip"
  source_dir  = "${path.module}/assets/lambda/aft-new-account-event-forwarder"
  output_path = "${path.module}/assets/lambda/aft-new-account-event-forwarder.zip"
}

data "aws_ssm_parameter" "aft_sns_notification_topic_arn" {
  count    = var.account_lifecycle_events_source == "AFT" ? 1 : 0
  provider = aws.event-source-account

  name = "/aft/account/aft-management/sns/topic-arn"
}

data "aws_ssm_parameter" "aft_management_account_id" {
  count    = var.account_lifecycle_events_source == "AFT" ? 1 : 0
  provider = aws.event-source-account

  name = "/aft/account/aft-management/account-id"
}
