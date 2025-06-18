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

    raw_bucket = event["detail"]["bucket"]["name"]
    s3_object_key = event["detail"]["object"]["key"]
    
    logger.info(f"s3_bucket: {raw_bucket}")
    logger.info(f"s3_object_key: {s3_object_key}")
    
    try:
        s3_client.copy_object(
            CopySource={
                "Bucket": raw_bucket,
                "Key": s3_object_key
            },
            Bucket=scan_bucket,
            Key=s3_object_key
        )
        s3_client.delete_object(
            Bucket=raw_bucket,
            Key=s3_object_key
        )
        s3_client.put_object_tagging(
            Bucket = scan_bucket,
            Key = s3_object_key,
            Tagging = {
                'TagSet': [
                    {
                        'Key': 'WorkflowId',
                        'Value': event["id"]
                    }
                ]
            }
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
        raise
    
    try:
        logger.info("Starting Macie Scan Job")
        response = macie_client.create_classification_job(
            description="File upload scan",
            initialRun=True,
            jobType="ONE_TIME",
            name=f"scan-{s3_object_key}-{event['id']}",
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
                                "tagScopeTerm": {
                                    "comparator": "EQ",
                                    "key": "TAG",
                                    "tagValues": [
                                        {
                                            "key": "WorkflowId",
                                            "value": event["id"]
                                        }
                                    ],
                                    'target': 'S3_OBJECT'
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
        raise
    
    return {
        "scan_bucket": scan_bucket,
        "s3_object_key": s3_object_key,
        "macie_job_id": response['jobId']
    }