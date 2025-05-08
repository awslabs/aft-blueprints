# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_guardduty_organization_configuration" "this" {
  auto_enable_organization_members = var.auto_enable_organization_members
  detector_id                      = data.aws_guardduty_detector.current.id

  datasources {
    s3_logs {
      auto_enable = lookup(var.datasources, "s3_logs", false)
    }
    kubernetes {
      audit_logs {
        enable = lookup(var.datasources, "kubernetes", false)
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          auto_enable = lookup(var.datasources, "malware_protection", false)
        }
      }
    }
  }
}

resource "aws_guardduty_organization_configuration_feature" "this" {
  # An issue in aws_guardduty_organization_configuration_feature and aws_guardduty_detector_feature resource 
  # makes terraform replace the additional configuration every time it runs.
  # https://github.com/hashicorp/terraform-provider-aws/issues/36400
  # https://github.com/hashicorp/terraform-provider-aws/issues/36695
  # https://github.com/hashicorp/terraform-provider-aws/pull/36985
  for_each   = { for k, v in var.organization_features : k => v if var.auto_enable_organization_members != "NONE" }
  depends_on = [aws_guardduty_organization_configuration.this]

  name        = each.key
  auto_enable = each.value
  detector_id = data.aws_guardduty_detector.current.id

  dynamic "additional_configuration" {
    for_each = { for k, v in var.additional_configuration : k => v if contains(["EKS_RUNTIME_MONITORING", "RUNTIME_MONITORING"], each.key) }
    content {
      name        = additional_configuration.key
      auto_enable = additional_configuration.value
    }

  }
}
