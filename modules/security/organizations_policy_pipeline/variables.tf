# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

variable "project_name" {
  description = "Project name"
  default     = "org-policy-mgmt"
}

variable "provider_type" {
  description = "The name of the external provider where your third-party code repository is configured. Valid values are Bitbucket, GitHub, GitHubEnterpriseServer, GitLab or GitLabSelfManaged"
  default     = "GitHub"
}

variable "full_repository_name" {
  description = "The name of the code repository where Organization Policies will be managed. Pattern would be 'org/repo_name'"  
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+/[a-zA-Z0-9-_]+$", var.full_repository_name))
    error_message = "Repository name must be in format 'org/repo'."
  }
  default     = "org/org-policy-mgmt-pipeline"
}

variable "branch_name" {
  description = "The name of the Git branch that will be used for Policies deployment"
  default     = "main"
}

variable "terraform_version" {
  description = "Terraform version to be used in the pipeline"
  type        = string
  default     = "1.9.8"
}

variable "enable_bedrock" {
  description = "Enable Amazon Bedrock to summarize pipeline logs for manual approval stage"
  type        = bool
  default     = true
}

variable "bedrock_model_id" {
  description = "If enable_bedrock is true, define the Bedrock model you want to use"
  type = string
  default = "global.anthropic.claude-sonnet-4-20250514-v1:0"
}

variable "security_gate" {
  description = "SCPs and RCP policies are analyzed by IAM Access Analyzer. Define which type of findings break the pipeline. Recommended at least ERROR and SECURITY_WARNING"
  validation {
    condition     = alltrue([for finding in var.security_gate : contains(["ERROR", "SECURITY_WARNING", "SUGGESTION", "WARNING"], finding)])
    error_message = "Valid values are ERROR, SECURITY_WARNING, SUGGESTION and WARNING"  
  }
  type = list(string)
  default = ["ERROR", "SECURITY_WARNING"]
}

variable "tags" {
  description = "Tags for resources"
  default = {
    environment = "prd"
    terraform   = "true"
  }
}