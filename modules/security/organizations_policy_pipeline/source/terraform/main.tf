# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
## +-------
## | UTILS
## +---------------------------------

terraform {
  required_version = ">=1.9.8"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~>6.0"
    }
  }
  backend "s3" {
  }  
}

locals {
  # Import raw JSON content into a variable
  scps_raw = jsondecode(file("${path.module}/scps.json"))
  rcps_raw = jsondecode(file("${path.module}/rcps.json"))

  # Create a map for the policies, grouping by sid. The '...' allows multiple items with the same sid to be grouped into a list

  #SCP Map
  scps_map = {
    for scp in local.scps_raw :
    scp.sid => {
      sid    = scp.sid
      comments    = scp.comments
      policy = jsonencode(scp.policy)
    }...
  }

  #RCP Map
  rcps_map = {
    for rcp in local.rcps_raw :
    rcp.sid => {
      sid    = rcp.sid
      comments    = rcp.comments
      policy = jsonencode(rcp.policy)
    }...
  }

  # Create a final list of unique policies. For each sid group, take only the first occurrence (items[0]). This effectively removes duplicates while keeping one copy of each policy
  
  #SCP list
  scps_processed = [
    for sid, items in local.scps_map :
    {
      sid    = sid
      comments    = items[0].comments
      policy = items[0].policy
    }
  ]

  #RCP list
  rcps_processed = [
    for sid, items in local.rcps_map :
    {
      sid    = sid
      comments    = items[0].comments
      policy = items[0].policy
    }
  ]

  # Create a mapping for policy attachments

  #SCP attachments
  scps_attachments = {
    for policy in local.scps_raw :
    "${policy.sid}-${policy.target_id}" => policy
  }

  #RCP attachments
  rcps_attachments = {
    for policy in local.rcps_raw :
    "${policy.sid}-${policy.target_id}" => policy
  }
}


## +-------
## | SERVICE CONTROL POLICY (SCP)
## +---------------------------------

# Create the SCP policies in AWS Organizations
resource "aws_organizations_policy" "scp_policy" {
  for_each = { for policy in local.scps_processed : policy.sid => policy }

  name        = "scp-mgmt-${each.value.sid}"
  description = "SCP Policy for ${each.value.comments}"
  content     = each.value.policy
  type        = "SERVICE_CONTROL_POLICY"
}

# Create the attachments between SCP policies and their targets
resource "aws_organizations_policy_attachment" "scp_attachment" {
  for_each = local.scps_attachments

  policy_id = aws_organizations_policy.scp_policy[each.value.sid].id
  target_id = each.value.target_id
}


## +-------
## | RESOURCE CONTROL POLICY (RCP)
## +---------------------------------

# Create the RCP policies in AWS Organizations
resource "aws_organizations_policy" "rcp_policy" {
  for_each = { for policy in local.rcps_processed : policy.sid => policy }

  name        = "rcp-mgmt-${each.value.sid}"
  description = "RCP Policy for ${each.value.comments}"
  content     = each.value.policy
  type        = "RESOURCE_CONTROL_POLICY"
}

# Create the attachments between RCP policies and their targets
resource "aws_organizations_policy_attachment" "rcp_attachment" {
  for_each = local.rcps_attachments

  policy_id = aws_organizations_policy.rcp_policy[each.value.sid].id
  target_id = each.value.target_id
}