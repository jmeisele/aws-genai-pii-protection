import json
import logging
import os

import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3_client = boto3.client('s3')
scan_bucket = os.environ["SCAN_BUCKET"]
clean_bucket = os.environ["CLEAN_BUCKET"]

def lambda_handler(event: dict, context: dict) -> dict:
    logger.info(f"event: {event}")
    logger.info(f"context: {context}")
    scan_bucket = event['scan_bucket']
    macie_job_id = event['macie_job_id']
    s3_object_key = event['s3_object_key']

    try:
        s3_client.copy_object(
            CopySource={
                "Bucket": scan_bucket,
                "Key": s3_object_key
            },
            Bucket=clean_bucket,
            Key=s3_object_key
        )
        s3_client.delete_object(
            Bucket=scan_bucket,
            Key=s3_object_key
        )
        s3_client.put_object_tagging(
            Bucket = clean_bucket,
            Key = s3_object_key,
            Tagging = {
                'TagSet': [
                    {
                        'Key': 'macie_job_id',
                        'Value': macie_job_id
                    }
                ]
            }
        )
    except Exception as e:
        logger.exception(e)
        raise