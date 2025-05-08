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

variable "vcs_provider" {
  description = "Customer VCS Provider - valid inputs are codecommit, github, or githubenterprise"
  type        = string
  default     = "github"
  validation {
    condition     = contains(["codecommit", "github", "githubenterprise"], var.vcs_provider)
    error_message = "Valid values for vcs_provider are: codecommit, github githubenterprise"
  }
}

variable "github_enterprise_url" {
  description = "GitHub enterprise URL, if GitHub Enterprise is being used. (inform only if vcs_provider = githubenterprise)"
  type        = string
  default     = "null"
}

variable "enable_vpc_config" {
  description = "Enable VPC configuration for CodeBuild project and CodeConnections Host."
  type        = bool
  default     = false
}

variable "vpc_config" {
  description = "VPC configuration to set to CodeBuild project and CodeConnections Host. (enable_vpc_config must be true)"
  type = object({
    vpc_id          = string
    subnets         = list(string)
    security_groups = list(string)
  })
  default = {
    vpc_id          = ""
    subnets         = []
    security_groups = []
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

      - If you don't want to use account lifecycle events to trigger the pipeline, select None and inform the aws default provider:
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
