# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

import json
import os
import sys
from utils import mergeandoptimize
import logging
import boto3

# Create a logger
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
logger.propagate = False

# Create handlers
file_handler = logging.FileHandler("rcp.log")
console_handler = logging.StreamHandler()

# Set logging levels for handlers
file_handler.setLevel(logging.INFO)
console_handler.setLevel(logging.INFO)

# Create formatters and add it to handlers
formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
file_handler.setFormatter(formatter)
console_handler.setFormatter(formatter)

# Add handlers to the logger
logger.addHandler(file_handler)
logger.addHandler(console_handler)


# Files and folders
RCP_MANAGEMENT_FILE_NAME = "rcp-management.json"
RCP_MANAGEMENT_FILE_PATH = (
    os.getcwd() + "/../../" + "rcp-management/" + RCP_MANAGEMENT_FILE_NAME
)

ENVIRONMENT_FILE_NAME = "environments.json"
ENVIRONMENT_FILE_PATH = os.getcwd() + "/../../environments/" + ENVIRONMENT_FILE_NAME

GUARDRAIL_FOLDER = os.getcwd() + "/../../" + "rcp-management/guardrails/"
POLICY_FOLDER = os.getcwd() + "/../../" + "rcp-management/policies/"

SECURITY_GATE = os.getenv("SECURITY_GATE", ["ERROR", "SECURITY_WARNING"])


def main():

    logger.info("#################################")
    logger.info("# Starting RCP Policy Processor #")
    logger.info("#################################\n")

    # Load content from RCP management file
    rcps = []
    with open(RCP_MANAGEMENT_FILE_PATH, "r") as f:
        data = json.load(f)

    with open(ENVIRONMENT_FILE_PATH, "r") as g:
        environment_ou_list = json.load(g)

    # Validate if "SID" field are unique
    sid_set = set()
    for item in data:
        sid = item.get("SID")
        if sid in sid_set:
            logger.error(
                f"[!] SIDs are not unique. Please, review {RCP_MANAGEMENT_FILE_NAME} file."
            )
            sys.exit(1)
        sid_set.add(sid)
    logger.info("SIDs are unique")

    # Create rcps.json file for import in Terraform
    for statement in data:
        if statement == {}:
            logger.error(
                f"[!] Empty statement found. Please, review {RCP_MANAGEMENT_FILE_NAME} file."
            )
            sys.exit(1)
        logger.info("[*] Processing statement ID: " + str(statement["SID"]))
        rcp_statement = {}

        # Checks if statement is using GUARDRAIL or POLICY
        if statement["Guardrails"] != []:
            logger.info(
                f"Guardrails are being used for SID {statement['SID']}: {statement['Guardrails']}"
            )
            optmized_policy = mergeandoptimize.mergeguardrails(
                statement["Guardrails"], GUARDRAIL_FOLDER, SECURITY_GATE
            )
        elif statement["Policy"] != "":
            logger.info(
                f"Individual policy is being used for SID {statement['SID']}: {statement['Policy']}"
            )
            with open(POLICY_FOLDER + str(statement["Policy"]) + ".json", "r") as h:
                policy_content = json.load(h)

            # Validate individual policy with Access Analyzer
            logger.info(
                f"Validating individual RCP policy '{statement['Policy']}' with Access Analyzer"
            )
            logger.info(f"Security Gate: {SECURITY_GATE}")
            access_analyzer_client = boto3.client("accessanalyzer")

            findings = []
            paginator = access_analyzer_client.get_paginator("validate_policy")

            for page in paginator.paginate(
                locale="EN",
                policyDocument=json.dumps(policy_content),
                policyType="RESOURCE_CONTROL_POLICY",
            ):
                findings.extend(page["findings"])

            if findings:
                critical_findings = [
                    finding
                    for finding in findings
                    if finding.get("findingType") in SECURITY_GATE
                ]

                if critical_findings:
                    logger.critical(
                        f"[!] Findings were found in RCP policy {statement['Policy']}: {json.dumps(critical_findings, indent=4)}"
                    )
                    sys.exit(1)
                else:
                    logger.warning(
                        f"Non-critical findings were found in RCP policy {statement['Policy']}: {json.dumps(findings, indent=4)}"
                    )
            else:
                logger.info("No findings found")
            optmized_policy = policy_content
        else:
            logger.error(
                "[!] No policy or guardrails found for statement ID: "
                + str(statement["SID"])
            )
            sys.exit(1)

        # Checks the target Type
        if (
            statement["Target"]["Type"] == "Account"
            or statement["Target"]["Type"] == "OU"
        ):
            logger.info(f"Target type is {statement['Target']['Type']}")
            rcp_statement["target_id"] = statement["Target"]["ID"].split(":")[1]
            rcp_statement["sid"] = statement["SID"]
            rcp_statement["comments"] = statement["Comments"]
            rcp_statement["policy"] = optmized_policy
            rcps.append(rcp_statement.copy())
        elif statement["Target"]["Type"] == "Environment":
            logger.info(f"Target type is {statement['Target']['Type']}")
            targets = []
            for environment in environment_ou_list:
                if environment["ID"] == statement["Target"]["ID"]:
                    logger.info(f'Environment ID found: {environment["ID"]}')
                    targets = environment["Target"].copy()

            if targets == []:
                logger.error(
                    f"Environment ID not found for SID {statement['SID']}: {statement['Target']['ID']}"
                )
                sys.exit(1)

            logger.info(
                f"The environment {statement['Target']['Type']} has the following targets: {targets}"
            )
            for each_target in targets:
                rcp_statement["target_id"] = each_target.split(":")[1]
                rcp_statement["policy"] = optmized_policy
                rcp_statement["sid"] = statement["SID"]
                rcp_statement["comments"] = statement["Comments"]
                rcps.append(rcp_statement.copy())
        elif statement["Target"]["Type"] == "Tag":
            logger.info(f"Target type is {statement['Target']['Type']}")
            targets = get_aws_accounts_by_tag(
                statement["Target"]["ID"].split(":")[0],
                statement["Target"]["ID"].split(":")[1],
            )

            for each_accountid in targets:
                rcp_statement["target_id"] = each_accountid
                rcp_statement["policy"] = optmized_policy
                rcp_statement["sid"] = statement["SID"]
                rcp_statement["comments"] = statement["Comments"]
                rcps.append(rcp_statement.copy())
        else:
            logger.error("[!] Invalid Target Type: " + str(statement["Target"]["Type"]))
            sys.exit(1)

        print()
    with open("../terraform/rcps.json", "w") as o:
        json.dump(rcps, o)


def get_aws_accounts_by_tag(tag_key, tag_value):
    try:
        # Create organizations client
        org_client = boto3.client("organizations")

        # List all accounts with pagination
        accounts = []
        paginator = org_client.get_paginator("list_accounts")

        for page in paginator.paginate():
            accounts.extend(page["Accounts"])

        # Get accounts with matching tag
        matching_accounts = []

        for account in accounts:
            # Get tags for each account
            tags = org_client.list_tags_for_resource(ResourceId=account["Id"])["Tags"]

            # Check if account has matching tag
            for tag in tags:
                if tag["Key"] == tag_key and tag["Value"] == tag_value:
                    matching_accounts.append(account["Id"])
                    break

        return matching_accounts

    except Exception as e:
        print(f"Error getting accounts by tag: {str(e)}")
        return []


main()
