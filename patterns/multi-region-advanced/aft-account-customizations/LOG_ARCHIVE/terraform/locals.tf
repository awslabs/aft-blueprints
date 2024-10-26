# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

locals {
  tags = jsondecode(lookup(module.aft_custom_fields.values, "tags", "{}"))
}
