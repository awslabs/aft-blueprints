# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

import os
import boto3
import json
import sys

inference_profile = os.getenv(
    "INFERENCE_PROFILE", "global.anthropic.claude-sonnet-4-5-20250929-v1:0"
)

try:
    model_id = json.loads(inference_profile)
except json.JSONDecodeError:
    model_id = inference_profile


def load_prompt():
    with open("../bedrock-prompt/prompt.txt", "r") as file:
        return file.read()


def concatenate_logs():
    parent_dir = "."
    concatenated_logs = ""
    log_files = ["scp.log", "rcp.log", "tf.log"]

    for log_file in log_files:
        file_path = os.path.join(parent_dir, log_file)
        if os.path.exists(file_path):
            with open(file_path, "r") as file:
                concatenated_logs += file.read() + "\n\n"
        else:
            print(f"Warning: {log_file} not found in the parent directory.")
            sys.exit(1)

    return concatenated_logs


def query_bedrock(prompt):
    bedrock = boto3.client(service_name="bedrock-runtime")

    body = json.dumps(
        {
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 4096,
            "messages": [{"role": "user", "content": prompt}],
            "temperature": 0,
        }
    )

    accept = "application/json"
    contentType = "application/json"

    response = bedrock.invoke_model_with_response_stream(
        body=body, accept=accept, contentType=contentType, modelId=model_id
    )

    full_response = ""
    for event in response.get("body"):
        chunk = json.loads(event.get("chunk").get("bytes").decode())
        if "delta" in chunk:
            if "text" in chunk["delta"]:
                full_response += chunk["delta"]["text"]
        elif "message" in chunk:
            if "content" in chunk["message"]:
                content = chunk["message"]["content"]
                if isinstance(content, list):
                    for item in content:
                        if isinstance(item, dict) and "text" in item:
                            full_response += item["text"]
                        else:
                            full_response += str(item)
                else:
                    full_response += str(content)

    return full_response


# Main execution
prompt = load_prompt()
pipeline_logs = concatenate_logs()
prompt += pipeline_logs
prompt += "\n</Pipeline Logs>"
prompt += "Assistant:"

response = query_bedrock(prompt)

print("####################################")
print("######## Gen AI Log Summary #######")
print("####################################")
print()
print()
print(response)

with open("summary.txt", "w") as file:
    file.write(response)
