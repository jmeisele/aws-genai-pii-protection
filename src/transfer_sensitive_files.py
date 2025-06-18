import json
import logging
import os

import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambdas_handler(event: dict, context: dict) -> dict:
    logger.info(f"event: {event}")
    logger.info(f"context: {context}")