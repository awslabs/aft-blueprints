# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

output "vpc_id" {
  value = try(module.vpc[0].vpc_id, null)
}

output "phz_id" {
  value = try(module.phz[0].zone_id, null)
}

output "instance_id" {
  value = try(module.bastion[0].instance_id, null)
}
