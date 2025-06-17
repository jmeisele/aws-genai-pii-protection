import json
import logging

import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)
macie_client = boto3.client('macie2')

def lambda_handler(event: dict,  context: dict) -> dict:
    logger.info(f"Event: {event}")
    logger.info(f"Context: {context}")
    job_id = event['Input']['jobId']['Payload']

    if job_id == 'NoKeysFound':
        return 'NoKeysFound'
    
    try:
        response = macie_client.describe_classification_job(jobId=job_id)
    except Exception as e:
        logger.error(e)
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body":
             json.dumps(e),
        }
    
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(response['jobStatus']),
    }
    