# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
resource "aws_sfn_state_machine" "aft_account_provisioning_customizations" {
  #checkov:skip=CKV_AWS_284: This is the AFT default state machine for account provisioning customizations, we are not changing anything here.
  #checkov:skip=CKV_AWS_285: This is the AFT default state machine for account provisioning customizations, we are not changing anything here.
  name       = "aft-account-provisioning-customizations"
  role_arn   = aws_iam_role.aft_states.arn
  definition = templatefile("${path.module}/states/customizations.asl.json", {})
}
