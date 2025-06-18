import logging

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)
macie_client = boto3.client('macie2')

def lambda_handler(event: dict, context: dict) -> dict:
    logger.info(f"event: {event}")
    logger.info(f"context: {context}")
    job_id = event["macie_job_id"]

    response  = macie_client.list_findings(
        findingCriteria={
            "criterion": {
                'classificationDetails.jobId': {
                    'eq': [job_id]
                }
            }
        }
    )
    logger.info(f"response : {response}")