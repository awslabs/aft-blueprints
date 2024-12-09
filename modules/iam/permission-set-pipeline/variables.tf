# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

variable "solution_name" {
  description = "Solution name."
  type        = string
  default     = "aws-ps-pipeline"
}

variable "repository_name" {
  description = "VCS repository name. For external VCS, inform the full repository path (e.g. GitHubOrganization/repository-name)."
  type        = string
  default     = "aws-ps-pipeline"
}

variable "branch_name" {
  description = "Repository main branch name."
  type        = string
  default     = "main"
}

variable "use_code_connection" {
  description = "Whether to use a code connection for external VCS (e.g GitHub)"
  type        = bool
  default     = true
}

variable "code_connection_name" {
  description = "Code connection name"
  type        = string
  default     = "aws-ps-pipeline-connection"
}

variable "code_connection_provider" {
  description = "Code connection provider"
  type        = string
  default     = "GitHub"
  validation {
    condition     = contains(["GitHub"], var.code_connection_provider)
    error_message = "Valid values for code_connection_provider are: GitHub"
  }
}

variable "account_lifecycle_events_source" {
  description = <<-EOF
    Define from where to capture account lifecycle events: AFT, Control Tower (CT) or None.
    Based on this choice, you also must change the provider for the source account (aws.event-source-account).
    For exemple:

      - For AFT as the source account, inform the provider with access to AFT management account:
        ```
          providers = {
            aws.event-source-account = aws.aft-management
          }
        ```

      - For CT as the source account, inform the provider with access to CT management account:
        ```
          providers = {
            aws.event-source-account = aws.org-management
          }
        ```

      - If you don't want to use account lifecyle events to trigger the pipeline, select None and inform the aws default provider:
        ```
          providers = {
            aws.event-source-account = aws
          }
    ```
  EOF
  type        = string
  default     = "None"
  validation {
    condition     = contains(["AFT", "CT", "None"], var.account_lifecycle_events_source)
    error_message = "Valid values for account_lifecycle_events_source are: AFT, CT or None"
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
