# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

########################################
#######      IPAM Delegation     #######
########################################
resource "aws_vpc_ipam_organization_admin_account" "ipam" {
  provider = aws.org-management

  delegated_admin_account_id = data.aws_caller_identity.current.account_id
}

########################################
#######     Global Resources     #######
########################################
module "ipam" {
  #checkov:skip=CKV_TF_1:The version has been specified
  #external module documentation: https://github.com/aws-ia/terraform-aws-ipam
  source  = "aws-ia/ipam/aws"
  version = "2.1.0"
  # Wating fixing issue https://github.com/aws-ia/terraform-aws-ipam/issues/67 to use depends_on
  # depends_on = [aws_organizations_delegated_administrator.ipam]

  top_cidr        = var.aws_ip_address_plan.global_cidr_blocks #var.aws_ip_address_plan.global_cidr_blocks
  top_name        = "global-ipam-pool"
  top_description = "Global AWS IPAM Pool"
  tags            = local.tags

  pool_configurations = {
    "${data.aws_region.primary.name}" = {
      name                     = "${data.aws_region.primary.name}-ipam-pool"
      description              = "${data.aws_region.primary.name}-ipam-pool"
      cidr                     = var.aws_ip_address_plan.primary_region.cidr_blocks
      locale                   = "${data.aws_region.primary.name}"
      allocation_resource_tags = {}
      tags                     = local.tags
      sub_pools = {
        shared = {
          name                              = "shared-ipam-pool"
          description                       = "shared-ipam-pool" #the description must be the name of the pool
          cidr                              = var.aws_ip_address_plan.primary_region.shared.cidr_blocks
          locale                            = "${data.aws_region.primary.name}"
          auto_import                       = "true"
          allocation_default_netmask_length = "23"
          allocation_max_netmask_length     = "24"
          allocation_min_netmask_length     = "21"
          ram_share_principals              = [data.aws_organizations_organization.org.arn]
          allocation_resource_tags          = {}
          tags                              = local.tags
        }
        prod = {
          name                              = "prod-ipam-pool"
          description                       = "prod-ipam-pool" #the description must be the name of the pool
          cidr                              = var.aws_ip_address_plan.primary_region.prod.cidr_blocks
          locale                            = "${data.aws_region.primary.name}"
          auto_import                       = "true"
          allocation_default_netmask_length = "23"
          allocation_max_netmask_length     = "24"
          allocation_min_netmask_length     = "21"
          ram_share_principals              = [data.aws_organizations_organization.org.arn]
          allocation_resource_tags          = {}
          tags                              = local.tags
        }
        stage = {
          name                              = "stage-ipam-pool"
          description                       = "stage-ipam-pool" #the description must be the name of the pool
          cidr                              = var.aws_ip_address_plan.primary_region.stage.cidr_blocks
          locale                            = "${data.aws_region.primary.name}"
          auto_import                       = "true"
          allocation_default_netmask_length = "23"
          allocation_max_netmask_length     = "24"
          allocation_min_netmask_length     = "21"
          ram_share_principals              = [data.aws_organizations_organization.org.arn]
          allocation_resource_tags          = {}
          tags                              = local.tags
        }
        dev = {
          name                              = "dev-ipam-pool"
          description                       = "dev-ipam-pool" #the description must be the name of the pool
          cidr                              = var.aws_ip_address_plan.primary_region.dev.cidr_blocks
          locale                            = "${data.aws_region.primary.name}"
          auto_import                       = "true"
          allocation_default_netmask_length = "23"
          allocation_max_netmask_length     = "24"
          allocation_min_netmask_length     = "21"
          ram_share_principals              = [data.aws_organizations_organization.org.arn]
          allocation_resource_tags          = {}
          tags                              = local.tags
        }
      }
    }
  }
}
