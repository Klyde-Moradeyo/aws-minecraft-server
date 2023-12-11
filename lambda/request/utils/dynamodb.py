import time
from datetime import datetime, timedelta
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
            item = {
                    "task_id": task_id,
                    "status": status,
                    "result": result,
                    "created_at": datetime.utcnow().isoformat(),
                    "last_updated": datetime.utcnow().isoformat(),
                    "TTL": self.calculate_ttl(ttl)  # Time To Live - in hours
                }
            self.table.put_item(
                Item=item
            )
            self.logger.info(f"Update item with: '{item}'")
        except ClientError as e:
            self.logger.error(f"Error updating DynamoDB: {e}")
            raise

    def update_task_attribute(self, task_id, attribute_key, attribute_value):
        """
        Update a specific key in a DynamoDB table.
        """
        try:
            key = {'task_id': task_id}

            self.table.update_item(
                Key=key,
                UpdateExpression=f"SET {attribute_key} = :val",
                ExpressionAttributeValues={
                    ':val': attribute_value
                }
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

    def calculate_ttl(self, hours_until_expiration=24):
        """
        Calculate the Time to Live (TTL) for a DynamoDB item.
        """
        # Ensure that the input is a positive integer
        if not isinstance(hours_until_expiration, int) or hours_until_expiration < 0:
            raise ValueError("Hours until expiration must be a positive integer.")

        # Calculate the expiration time
        expiration_time = datetime.utcnow() + timedelta(hours=hours_until_expiration)

        # Convert to UNIX timestamp
        ttl_unix_timestamp = int(time.mktime(expiration_time.timetuple()))

        return ttl_unix_timestamp
