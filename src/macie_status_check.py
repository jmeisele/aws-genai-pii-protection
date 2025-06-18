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
    job_id = event['macie_job_id']

    try:
        response = macie_client.describe_classification_job(jobId=job_id)
    except Exception as e:
        logger.exception(e)
        raise

    return {
        "macie_job_id": job_id,
        "job_status": response['jobStatus'],
    }
    