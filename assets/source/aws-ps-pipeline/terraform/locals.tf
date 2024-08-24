# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

locals {
  sso_instance_arn = tolist(data.aws_ssoadmin_instances.sso.arns)[0]
  ps_files         = fileset("../templates/", "*.json")
  ps_data          = [for f in local.ps_files : jsondecode(file("../templates/${f}"))]
  ps_definition    = zipmap([for data in local.ps_data : data.Name], local.ps_data)

  ps_ou_list = distinct(concat(flatten(flatten([
    for assignments in local.ps_data[*].Assignments : [
      for item in assignments : lookup(item, "account_ou", [])
    ]])))
  )

  ps_managed_policies = {
    for i in flatten([for ps, data in local.ps_definition :
      flatten([for policy in lookup(data, "ManagedPolicies", []) :
        {
          "ps"     = ps
          "policy" = policy
        }
      ])
    ]) : "${i.ps}_${replace(replace(i.policy, "arn:aws:iam::aws:policy/", ""), "job-function/", "")}" => i
  }

  ps_customer_policies = {
    for i in flatten([for ps, data in local.ps_definition :
      flatten([for policy in lookup(data, "CustomerPolicies", []) :
        {
          "ps"              = ps
          "customer_policy" = policy
        }
      ])
    ]) : "${i.ps}_${i.customer_policy}" => i
  }

  ps_boundaries = {
    for i in flatten([for ps, data in local.ps_definition :
      {
        "ps"              = ps
        "policy"          = lookup(lookup(data, "PermissionBoundary", {}), "ManagedPolicy", "")
        "customer_policy" = lookup(lookup(data, "PermissionBoundary", {}), "CustomerPolicy", "")
      }
    ]) : "${i.ps}_boundary_${i.customer_policy}${replace(replace(i.policy, "arn:aws:iam::aws:policy/", ""), "job-function/", "")}" => i
  }

  ps_groups = distinct(flatten([for data in local.ps_data :
    [for item in data.Assignments : { "Name" = lookup(item, "principal") } if item.type == "GROUP"]
  ]))

  ps_users = distinct(flatten([for data in local.ps_data :
    [for item in data.Assignments : { "Name" = lookup(item, "principal") } if item.type == "USER"]
  ]))

  org_accounts = [
    for acc in data.aws_organizations_organizational_unit_descendant_accounts.org_accounts.accounts[*] : acc.id if acc.id != data.aws_organizations_organization.org.master_account_id
  ]

  org_ou_accounts = {
    for ou in local.ps_ou_list : ou => flatten([
      data.aws_organizations_organizational_unit_descendant_accounts.accounts_per_ou[ou].accounts[*].id
    ])
  }

  org_account_tags = { for key, value in data.aws_organizations_resource_tags.account_tags : key => [
    for k, v in value.tags : lower("${k}_${v}")]
  }

  assignments = flatten([
    for data in local.ps_data : [
      for assignment in data.Assignments : [
        for account in lookup(assignment, "all_accounts", false) ? local.org_accounts : distinct(
          concat(
            lookup(assignment, "account_id", []),
            flatten([for ou in lookup(assignment, "account_ou", []) : local.org_ou_accounts[ou]]),
            flatten([for key, value in lookup(assignment, "account_tag", {}) : [
              for k, v in local.org_account_tags : k if contains(v, lower("${key}_${value}"))
            ]])
          )) : {
          "ps" : data.Name
          "principal_id" : lookup(assignment, "principal")
          "principal_type" : lookup(assignment, "type")
          "account_id" : account
        }
      ]
    ]
  ])
}
