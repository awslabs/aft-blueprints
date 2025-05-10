# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

locals {
  account_id              = var.account_id == "" ? data.aws_caller_identity.current.account_id : var.account_id
  attachment_name         = "${local.account_id}-tgw-attach-${var.vpc_name}"
  tgw_id                  = data.aws_ssm_parameter.tgw_id.insecure_value
  tgw_rt_association_id   = data.aws_ssm_parameter.rt_association.insecure_value
  tgw_rt_propagation_rule = toset(jsondecode(data.aws_ssm_parameter.propagation_rules.insecure_value)[var.route_table_name])
  tgw_rt_propagation_ids  = { for rt in local.tgw_rt_propagation_rule : rt => data.aws_ssm_parameter.rt_propagations[rt].insecure_value }
}
