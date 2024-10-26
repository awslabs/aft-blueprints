# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
module "ct_security_tooling" {
  source = "./modules/aft-account-request"

  control_tower_parameters = {
    AccountEmail = "my-org+ct-security-tooling@customer.com"
    AccountName  = "Security Tooling"
    # Syntax for top-level OU
    ManagedOrganizationalUnit = "Security"
    # Syntax for nested OU
    # ManagedOrganizationalUnit = "Sandbox (ou-abcd-12345678)"
    SSOUserEmail     = "my-org@customer.com"
    SSOUserFirstName = "AWS Control Tower"
    SSOUserLastName  = "Admin"
  }

  account_tags = {
    owner = "user"
  }

  change_management_parameters = {
    change_requested_by = "user"
    change_reason       = "Onboarding the Control Tower Security Tooling account to AFT"
  }

  custom_fields = {
    tags = jsonencode({
      env = "prod"
    })
  }

  account_customizations_name = "SECURITY"
}
