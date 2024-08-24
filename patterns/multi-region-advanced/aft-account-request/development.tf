# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
module "development" {
  source = "./modules/aft-account-request"

  control_tower_parameters = {
    AccountEmail = "vinelias+cfa-development@amazon.com"
    AccountName  = "CFA-Development"
    # Syntax for top-level OU
    ManagedOrganizationalUnit = "Development"
    # Syntax for nested OU
    # ManagedOrganizationalUnit = "Sandbox (ou-xfe5-a8hb8ml8)"
    SSOUserEmail     = "vinelias+cfa@amazon.com"
    SSOUserFirstName = "AWS Control Tower"
    SSOUserLastName  = "Admin"
  }

  account_tags = {
    owner = "vinelias"
  }

  change_management_parameters = {
    change_requested_by = "vinelias"
    change_reason       = "Testing the account vending process"
  }

  custom_fields = {
    phz_name = "myapp.dev.on.aws"
    vpc = jsonencode({
      environment = "dev"
      vpc_size    = "small"
    })
    tags = jsonencode({
      env = "dev"
    })
    features = jsonencode({
      ebs_encryption = false
      imdsv2         = false
    })
    ou = "Development"
  }

  account_customizations_name = "APP_DEV"
}
