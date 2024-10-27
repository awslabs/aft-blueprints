#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#

# Disclaimer: This shell script is being used as a workaround. There is currently no
# Terraform resource available to perform this specific task.

echo "Executing Pre-API Helpers"

#Enforce Amazon GuardDuty service trusted access for AWS Organizations
aws organizations enable-aws-service-access --service-principal guardduty.amazonaws.com --profile ct-management
aws organizations enable-aws-service-access --service-principal malware-protection.guardduty.amazonaws.com --profile ct-management

#Enforce AWS Security Hub service trusted access for AWS Organizations
aws organizations enable-aws-service-access --service-principal securityhub.amazonaws.com --profile ct-management
