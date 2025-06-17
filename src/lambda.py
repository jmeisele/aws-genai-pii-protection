import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event: dict, context: dict) -> None:
    logger.info(f"Event: {event}")
    logger.info(f"Context: {context}")
    return event