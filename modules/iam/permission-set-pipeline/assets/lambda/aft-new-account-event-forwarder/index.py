"""
(c) 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""

import sys
import logging
import json
import os
import boto3
from botocore.config import Config

# Logging configuration
logging.basicConfig(stream=sys.stdout, level=logging.INFO)
log = logging.getLogger()
log.setLevel(logging.INFO)

# Config to handle throttling for each boto3 client
config = Config(retries={"max_attempts": 50, "mode": "adaptive"})

# Boto client
client = boto3.client("events")


def lambda_handler(event, context):
    """Lambda handler for new account event forwarder"""

    try:
        log.info("Incoming event: %s", json.dumps(event))
        for record in event["Records"]:
            message = json.loads(record["Sns"]["Message"])
            response = client.put_events(
                Entries=[
                    {
                        "Source": "aft-new-account-event-forwarder",
                        "DetailType": message["Input"]["control_tower_event"][
                            "detail-type"
                        ],
                        "Detail": json.dumps(
                            message["Input"]["control_tower_event"]["detail"]
                        ),
                        "EventBusName": os.environ.get("EVENT_BUS_ARN"),
                    }
                ]
            )
            log.info(
                "Event sent: %s",
                json.dumps(message["Input"]["control_tower_event"]["detail"]),
            )
            log.debug(json.dumps(response))
            return response
    except Exception as e:
        log.error(str(e))
        raise e
