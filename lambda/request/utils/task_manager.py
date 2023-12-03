import uuid
import json
import os
import boto3
from datetime import datetime
from .logger import setup_logging

class TaskManager:
    def __init__(self, table_name):
        self.logger = setup_logging()
        self.lambda_client = boto3.client("lambda")
        self.dynamodb = boto3.resource("dynamodb")
        self.table = self.dynamodb.Table(os.environ["DYNAMODB_TABLE_NAME"])

    def process_task(self, task_data):
        # Generate a unique task ID
        task_id = self._create_unique_task_id()

        # Asynchronously invoke the Worker Lambda
        self._invoke_worker_lambda(task_data, task_id)

        # Update DynamoDB table
        self._update_dynamodb(task_id)

        return task_id

    def _invoke_worker_lambda(self, task_data, task_id):
        try:
            self.lambda_client.invoke(
                FunctionName=os.environ["WORKER_LAMBDA_NAME"],
                InvocationType="Event",
                Payload=json.dumps({"task_id": task_id, **task_data})
            )
        except Exception as e:
            self.logger.error(f"Error invoking worker lambda: {e}")
            raise

    def _update_dynamodb(self, task_id):
        try:
            self.table.put_item(
                Item={
                    "task_id": task_id,
                    "status": "PENDING",
                    "result": None,
                    "created_at": datetime.utcnow().isoformat(),
                    "TTL": None  # Time To Live - How long this record should stay in dynamobdb
                }
            )
        except Exception as e:
            self.logger.error(f"Error updating DynamoDB: {e}")
            raise

    def check_task_status(self, task_id):
        """
        Check the status of a task by task_id in DynamoDB.
        """
        try:
            response = self.table.get_item(
                Key={"task_id": task_id}
            )
            if "Item" in response:
                return response["Item"]
            else:
                return None
        except Exception as e:
            self.logger.error(f"Error retrieving task status from DynamoDB: {e}")
            raise

    @staticmethod
    def _generate_id():
        return str(uuid.uuid4())

    @staticmethod
    def _is_id_unique(task_id, data_store):
        # Check if the task_id is unique in the data_store
        # This could be a query to a database or an in-memory store
        return not data_store.exists(task_id)

    @staticmethod
    def _create_unique_task_id(data_store):
        while True:
            task_id = TaskManager._generate_id()
            if TaskManager._is_id_unique(task_id, data_store):
                return task_id
