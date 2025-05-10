# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

data "aws_ssm_parameters_by_path" "parameters" {
  path = var.path
}

