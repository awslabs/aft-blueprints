# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

locals {
  aft_custom_fields = {
    for i, v in data.aws_ssm_parameters_by_path.aft_custom_fields.names :
    split("/", v)[4] => nonsensitive(data.aws_ssm_parameters_by_path.aft_custom_fields.values)[i]
  }
}
