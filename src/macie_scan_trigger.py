import json
import logging
import os

import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

macie_client = boto3.client('macie2')
s3_client = boto3.client('s3')
raw_bucket = os.environ["RAW_BUCKET"]
scan_bucket = os.environ["SCAN_BUCKET"]
aws_account = os.environ["AWS_ACCOUNT"]

def lambda_handler(event: dict, context: dict) -> dict:
    logger.info(f"Event: {event}")
    logger.info(f"Context: {context}")

    s3_bucket = event["Records"][0]["s3"]["bucket"]["name"]
    s3_object_key = event["Records"][0]["s3"]["object"]["key"]
    
    logger.info(f"s3_bucket: {s3_bucket}")
    logger.info(f"s3_object_key: {s3_object_key}")
    
    try:
        s3_client.copy_object(
            CopySource={
                "Bucket": s3_bucket,
                "Key": s3_object_key
            },
            Bucket=scan_bucket,
            Key=s3_object_key
        )
    except ClientError as e:
        logger.error(e)
        return {
            "statusCode": 400,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(e),
        }
    except Exception as e:
        logger.exception(e)
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(e),
        }
    
    try:
        logger.info("Starting Macie Scan Job")
        response = macie_client.create_classification_job(
            description="File upload scan",
            initialRun=True,
            jobType="ONE_TIME",
            name=f"Scan-{s3_object_key}",
            s3JobDefinition={
                "bucketDefinitions": [
                    {
                        "buckets": [scan_bucket],
                        "accountId": aws_account
                    }
                ],
                "scoping": {
                    "includes": {
                        "and": [
                            {
                                "simpleScopeTerm": {
                                    "comparator": "EQ",
                                    "key": "OBJECT_KEY",
                                    "values": [
                                        s3_object_key
                                    ]
                                }
                            }
                        ]
                    }
                }
            }
        )
        logger.info(f"Response: {response}")
    except Exception as e:
        logger.exception(e)
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(f"Could not scan object: {e}"),
        }
    
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(response['jobId']),
    }