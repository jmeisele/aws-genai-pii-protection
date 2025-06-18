import logging

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)
macie_client = boto3.client('macie2')

def lambda_handler(event: dict, context: dict) -> dict:
    logger.info(f"event: {event}")
    logger.info(f"context: {context}")
    job_id = event["macie_job_id"]
    scan_bucket = event['scan_bucket']
    s3_object_key = event['s3_object_key']
    
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
    if bool(response["findingIds"]):
        return {
            "macie_job_id": job_id,
            "sensitive_data_detected": True,
            "scan_bucket": scan_bucket,
            "s3_object_key": s3_object_key,
        }
    return {
        "macie_job_id": job_id,
        "sensitive_data_detected": False,
        "scan_bucket": scan_bucket,
        "s3_object_key": s3_object_key,
    }     