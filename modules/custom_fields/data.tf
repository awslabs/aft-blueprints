# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

data "aws_ssm_parameters_by_path" "aft_custom_fields" {
  path = "/aft/account-request/custom-fields"
}

