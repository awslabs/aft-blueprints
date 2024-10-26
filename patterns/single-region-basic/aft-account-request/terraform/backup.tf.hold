# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

module "backup" {
  source = "./modules/aft-account-request"

  control_tower_parameters = {
    AccountEmail = "my-org+backup@customer.com"
    AccountName  = "Backup"
    # Syntax for top-level OU
    ManagedOrganizationalUnit = "Infrastructure"
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
    change_reason       = "Testing the account vending process"
  }

  custom_fields = {
    tags = jsonencode({
      env = "shared"
    })
  }

  account_customizations_name = "BACKUP"
}
