# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

variable "linking_mode" {
  description = "Indicates whether to aggregate findings from all of the available Regions or from a specified list."
  type        = string
  default     = "NO_REGIONS"
  validation {
    condition     = contains(["NO_REGIONS", "ALL_REGIONS", "SPECIFIED_REGIONS", "ALL_REGIONS_EXCEPT_SPECIFIED"], var.linking_mode)
    error_message = "Invalid linking mode. Valid values are NO_REGIONS, ALL_REGIONS, SPECIFIED_REGIONS or ALL_REGIONS_EXCEPT_SPECIFIED."
  }
}

variable "specified_regions" {
  description = "List of regions to include or exclude (required if linking_mode is set to ALL_REGIONS_EXCEPT_SPECIFIED or SPECIFIED_REGIONS)."
  type        = list(string)
  default     = null
}

variable "auto_enable_accounts" {
  description = "Enable auto enable Security Hub for organization accounts."
  type        = bool
  default     = false
}

variable "auto_enable_standards" {
  description = "Enable auto enable Security Hub standards for organization accounts."
  type        = bool
  default     = false
}

variable "configuration_type" {
  description = "Configuration type for Security Hub."
  type        = string
  validation {
    condition     = contains(["CENTRAL", "LOCAL"], var.configuration_type)
    error_message = "Invalid configuration type. Valid values are CENTRAL or LOCAL."
  }
}
