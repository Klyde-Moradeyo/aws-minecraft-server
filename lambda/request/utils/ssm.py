import boto3
from .logger import setup_logging

class SSMUtil:
    def __init__(self):
        self.logger = setup_logging() # Setting up logging
        self.client = boto3.client('ssm')

    def send_param(self, command: str, type: str, ssm_path: str) -> None:
        self.client.put_parameter(
            Name=ssm_path,
            Value=command,
            Type=type,
            Overwrite=True
        )
        self.logger.info(f"Updated SSM Parameter '{ssm_path}' with '{command}'")

    def get_param(self, ssm_path: str) -> str:
        response = self.client.get_parameter(Name=ssm_path, WithDecryption=True)
        value = response["Parameter"]["Value"]
        self.logger.info(f"Retrieved value from from SSM Parameter: '{ssm_path}'")
        return value