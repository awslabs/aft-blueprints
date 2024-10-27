#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

echo "Executing Pre-API Helpers"

#Enforce AWS Resource Access Manager service trusted access for AWS Organizations
aws ram enable-sharing-with-aws-organization --profile ct-management

#Enforce Amazon VPC IP Address Manager (IPAM) service trusted access for AWS Organizations
aws organizations enable-aws-service-access --service-principal "ipam.amazonaws.com" --profile ct-management
