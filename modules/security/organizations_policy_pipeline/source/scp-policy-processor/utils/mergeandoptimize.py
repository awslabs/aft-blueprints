# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

import json
import boto3
from collections import OrderedDict
import logging
import sys
import copy
from botocore.config import Config

# Create a logger
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
logger.propagate = False

# Create handlers
file_handler = logging.FileHandler("scp.log")
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

# Config to handle throttling
config = Config(retries={"max_attempts": 1000, "mode": "adaptive"})


def mergeguardrails(guardrails_list, guardrails_folder, security_gate):
    logger.info("Concatenating function")
    policy = OrderedDict(
        [
            ("Version", "2012-10-17"),
            ("Statement", concatenate_policy_files(guardrails_list, guardrails_folder)),
        ]
    )
    logger.debug(f"Value for policy: {policy}")

    logger.info(
        f"Length of the concatenated policy BEFORE optimization: {len(str(policy))}"
    )

    optimized_policy = optimize_iam_policy(policy)
    logger.debug(f"Value for optimized_policy: {optimized_policy}")

    # Comparing if policy BEFORE and AFTER optmization has the same effect
    access_analyzer_client = boto3.client("accessanalyzer", config=config)

    # Adding a statement with 'Allow All" so it can be used in IAM Access Analyzer
    allow_all_statement = OrderedDict(
        [("Effect", "Allow"), ("Action", ["*"]), ("Resource", ["*"])]
    )
    temp_optimized_policy = copy.deepcopy(optimized_policy)
    temp_optimized_policy["Statement"].append(allow_all_statement)
    temp_original_policy = copy.deepcopy(policy)
    temp_original_policy["Statement"].append(allow_all_statement)

    # Comparing both policies with Access Analyer
    response1 = access_analyzer_client.check_no_new_access(
        newPolicyDocument=json.dumps(temp_optimized_policy),
        existingPolicyDocument=json.dumps(temp_original_policy),
        policyType="IDENTITY_POLICY",
    )
    response2 = access_analyzer_client.check_no_new_access(
        newPolicyDocument=json.dumps(temp_original_policy),
        existingPolicyDocument=json.dumps(temp_optimized_policy),
        policyType="IDENTITY_POLICY",
    )

    if response1["message"] == response2["message"]:
        logger.info("Optimized policy has the same effect")
    else:
        logger.critical(f"[!] Optimized policy has different effects")
        sys.exit(1)

    # Validation with IAM Access Analyzer for security findings
    logger.info("Validating SCP policy with Access Analyzer")
    findings = []
    paginator = access_analyzer_client.get_paginator("validate_policy")

    for page in paginator.paginate(
        locale="EN",
        policyDocument=json.dumps(optimized_policy),
        policyType="SERVICE_CONTROL_POLICY",
    ):
        findings.extend(page["findings"])

    if findings:
        critical_findings = [
            finding
            for finding in findings
            if finding.get("findingType") in security_gate
        ]

        if critical_findings:
            logger.critical(
                f"[!] Findings were found in SCP policy : {json.dumps(critical_findings, indent=4)}"
            )
            sys.exit(1)
        else:
            logger.warning(
                f"Non-critical findings were found in SCP policy : {json.dumps(findings, indent=4)}"
            )
    else:
        logger.info("No findings found")

    # Remove fields "SID" from statements to optmize size
    optimized_policy_no_sid = remove_sids_from_policy(optimized_policy)
    logger.debug(f"Value for optimized_policy_no_sid: {optimized_policy_no_sid}")

    logger.info(
        f"Length of the concatenated policy AFTER optimization: {len(str(optimized_policy_no_sid))}"
    )
    return optimized_policy_no_sid


def concatenate_policy_files(guardrails_list, guardrails_folder):
    """
    Function to concatenate multiple guardrails into a single policy
    """

    logger.info(
        f"The following guardrails will be merged in a single policy: {guardrails_list}"
    )
    file_contents = []
    for file_name in guardrails_list:
        file_full_path = f"{guardrails_folder}{file_name}.json"
        try:
            with open(file_full_path, "r") as file:
                content = json.load(file, object_pairs_hook=OrderedDict)
                file_contents.extend(
                    [
                        {k: v for k, v in statement.items() if k.lower() != "sid"}
                        for statement in content
                    ]
                )
        except json.JSONDecodeError:
            logger.error(f"[!] Error: {file_full_path} is not a valid file.")
    return file_contents


def remove_sids_from_policy(policy):
    """
    Function remove SID field from each statement to optimize size
    """

    if isinstance(policy, str):
        policy = json.loads(policy, object_pairs_hook=OrderedDict)

    new_policy = OrderedDict((k, v) for k, v in policy.items() if k != "Statement")
    new_policy["Statement"] = [
        {k: v for k, v in statement.items() if k.lower() != "sid"}
        for statement in policy.get("Statement", [])
    ]

    return new_policy


def normalize_condition(condition):
    """
    Recursively sort condition operators and their values to ensure consistent ordering
    """
    if isinstance(condition, dict):
        return OrderedDict(
            (k, normalize_condition(v)) for k, v in sorted(condition.items())
        )
    elif isinstance(condition, list):
        return sorted(condition)
    return condition


def normalize_resource(resource):
    """
    Normalize resource field to treat "*" and ["*"] as the same
    """
    if isinstance(resource, str):
        return [resource]
    elif isinstance(resource, list):
        return resource
    return []


def optimize_iam_policy(policy):
    """
    Function to optimize IAM policy with normalized condition ordering and resource handling.
    NotAction statements are kept separate to maintain their original security effects.
    """
    if isinstance(policy, str):
        policy = json.loads(policy, object_pairs_hook=OrderedDict)

    statements = policy.get("Statement", [])
    action_statements = []
    notaction_statements = []

    # First separate NotAction statements from Action statements
    for statement in statements:
        if "NotAction" in statement:
            notaction_statements.append(statement)
        else:
            action_statements.append(statement)

    # Only group and optimize Action statements
    grouped_statements = OrderedDict()
    for statement in action_statements:
        if "Action" in statement:
            # Normalize the condition before creating the key
            normalized_condition = normalize_condition(statement.get("Condition", {}))

            # Normalize the resource field
            resource = statement.get("Resource", ["*"])
            normalized_resource = normalize_resource(resource)

            # If resource is "*" or ["*"], standardize to ["*"]
            if normalized_resource == ["*"] or normalized_resource == "*":
                resource_key = json.dumps(["*"], sort_keys=True)
            else:
                resource_key = json.dumps(normalized_resource, sort_keys=True)

            key = (
                resource_key,
                json.dumps(normalized_condition, sort_keys=True),
                statement.get("Effect", ""),
            )
            grouped_statements.setdefault(key, []).append(statement)

    optimized_statements = []

    # Process Action statements
    for (resource, condition, effect), group in grouped_statements.items():
        if len(group) == 1:
            optimized_statements.append(group[0])
        else:
            merged_statement = OrderedDict(
                [
                    ("Effect", effect),
                    (
                        "Action",
                        sorted(
                            set(
                                action
                                for stmt in group
                                for action in (
                                    stmt.get("Action", [])
                                    if isinstance(stmt.get("Action"), list)
                                    else [stmt.get("Action")]
                                )
                            )
                        ),
                    ),
                    ("Resource", json.loads(resource)),
                ]
            )
            if condition != "{}":
                merged_statement["Condition"] = json.loads(
                    condition, object_pairs_hook=OrderedDict
                )
            optimized_statements.append(merged_statement)

    # Add all NotAction statements without any merging
    optimized_statements.extend(notaction_statements)

    optimized_policy = policy.copy()
    optimized_policy["Statement"] = optimized_statements

    return optimized_policy
