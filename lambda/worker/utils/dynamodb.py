import logging
from datetime import datetime
from .logger import setup_logging
import boto3
from botocore.exceptions import ClientError

class DynamoDBUtil:
    def __init__(self, table_name):
        self.logger = setup_logging() # Setting up logging
        self.dynamodb = boto3.resource("dynamodb")
        self.table = self.dynamodb.Table(table_name)

    def update_item(self, task_id, status, result=None, ttl=None):
        try:
            self.table.put_item(
                Item={
                    "task_id": task_id,
                    "status": status,
                    "result": result,
                    "created_at": datetime.utcnow().isoformat(),
                    "TTL": ttl  # Time To Live - Set as UNIX timestamp if used
                }
            )
            self.logger("Update item to ")
        except ClientError as e:
            self.logger.error(f"Error updating DynamoDB: {e}")
            raise

    def update_task_attribute(self, task_id, attribute_key, attribute_value):
        """
        Update a specific key in a DynamoDB table.
        """
        try:
            key = {'task_id': task_id}

            # Use expression attribute names to avoid reserved keyword issues
            expression_attribute_names = {'#attr_key': attribute_key}

            self.table.update_item(
                Key=key,
                UpdateExpression="SET #attr_key = :val",
                ExpressionAttributeValues={
                    ':val': attribute_value
                },
                ExpressionAttributeNames=expression_attribute_names
            )
            return True
        except ClientError as e:
            self.logger.error(f"Error updating DynamoDB: {e}")
            raise
        
    def get_task_status(self, task_id):
        try:
            response = self.table.get_item(Key={"task_id": task_id})
            return response.get("Item")
        except ClientError as e:
            self.logger.error(f"Error retrieving task status from DynamoDB: {e}")
            raise
