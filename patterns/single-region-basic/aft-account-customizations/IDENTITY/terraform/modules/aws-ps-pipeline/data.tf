# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

data "aws_organizations_organization" "org" {}

data "aws_ssoadmin_instances" "sso" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "local_file" "buildspec" {
  filename = "${path.module}/assets/buildspecs/buildspec.yml"
}

data "archive_file" "aft_new_account_forward_event" {
  count       = var.use_control_tower_events ? 0 : 1
  type        = "zip"
  source_dir  = "${path.module}/lambda/aft-new-account-forward-event"
  output_path = "${path.module}/lambda/aft-new-account-forward-event.zip"
}

data "aws_ssm_parameter" "aft_sns_notification_topic_arn" {
  count    = var.use_control_tower_events ? 0 : 1
  provider = aws.aft-management

  name = "/aft/account/aft-management/sns/topic-arn"
}

data "aws_ssm_parameter" "aft_management_account_id" {
  count    = var.use_control_tower_events ? 0 : 1
  provider = aws.aft-management

  name = "/aft/account/aft-management/account-id"
}