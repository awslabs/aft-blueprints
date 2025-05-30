# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

output "instance_id" {
  value       = aws_instance.bastion_linux.id
  description = "The EC2 instance id"
}
