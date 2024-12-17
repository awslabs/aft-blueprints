# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

variable "guardduty_auto_enable_organization_members" {
  description = "Define whether enable GuardDuty Organization Configuration or not."
  type        = string
  default     = "ALL"
  validation {
    condition     = contains(["ALL", "NEW", "NONE"], var.guardduty_auto_enable_organization_members)
    error_message = "Valid values are: ALL, NEW, and NONE."
  }
}

variable "securityhub_control_finding_generator" {
  description = "Define whether the Security Hub calling account has consolidated control findings turned on."
  type        = string
  default     = "SECURITY_CONTROL"
  validation {
    condition     = contains(["SECURITY_CONTROL", "STANDARD_CONTROL"], var.securityhub_control_finding_generator)
    error_message = "Valid values are: SECURITY_CONTROL, STANDARD_CONTROL."
  }
}

variable "securityhub_enabled_standard_arns" {
  description = "List of AWS Security Hub standard ARNs to enable."
  type        = list(string)
  default     = []
}

