# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

variable "vcs_provider" {
  description = "Customer VCS Provider - valid inputs are codecommit, github, or githubenterprise"
  type        = string
  default     = "github"
  validation {
    condition     = contains(["codecommit", "github", "githubenterprise"], var.vcs_provider)
    error_message = "Valid values for vcs_provider are: codecommit, github githubenterprise"
  }
}

variable "repository_name" {
  description = "Repository name for AWS Permission Set pipeline. For external VCS, inform the full repository path (e.g. GitHubOrganization/repository-name)."
  type        = string
  default     = "myorg/aws-ps-pipeline"
}

variable "branch_name" {
  description = "Repository main branch name for AWS Permission Set pipeline."
  type        = string
  default     = "main"
}
