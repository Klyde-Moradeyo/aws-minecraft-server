import boto3
from botocore.exceptions import ClientError
from .logger import setup_logging

def check_s3_object_exists(bucket_name, object_key):
    logger = setup_logging()
    s3 = boto3.client('s3')

    # Extract bucket name from uri
    if bucket_name.startswith("s3://"):
        bucket_name = bucket_name.split('/', 3)[2]
    
    try:
        s3.head_object(Bucket=bucket_name, Key=object_key)
        logger.info(f"Object '{object_key}' found in s3 bucket: '{bucket_name}'")
        return True
    except ClientError as e:
        logger.info(f"The object '{object_key}' does not exist or you lack permission to access it in s3 bucket: '{bucket_name}'")
        return False