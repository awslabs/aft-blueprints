# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

locals {
  region                    = data.aws_region.current.name
  attachment_name           = "${data.aws_caller_identity.current.account_id}-tgw-attach-${var.vpc_name}"
  use_association_parameter = var.tgw_rt_association_name != null ? true : false
  tgw_rt_association_id     = local.use_association_parameter ? try(data.aws_ssm_parameter.rt_association[0].insecure_value, "") : var.tgw_rt_association_id
  use_propagation_rules     = var.use_propagation_rules && var.tgw_rt_association_name != null ? true : false
  tgw_rt_propagations       = local.use_propagation_rules ? try({ for rt in toset(jsondecode(data.aws_ssm_parameter.propagation_rules[0].insecure_value)[var.tgw_rt_association_name]) : rt => data.aws_ssm_parameter.rt_propagations[rt].insecure_value }, {}) : var.tgw_rt_propagations
  tgw_id                    = var.use_tgw_id_parameter ? data.aws_ssm_parameter.tgw_id[0].insecure_value : var.tgw_id
}
