import uuid
import boto3
import os
import json
from datetime import datetime
from .logger import setup_logging
from .dynamodb import DynamoDBUtil

class TaskManager:
    def __init__(self, worker_lambda_name, table_name):
        self.logger = setup_logging()
        self.worker_lambda_name = worker_lambda_name
        self.lambda_client = boto3.client("lambda")
        self.dynamodb_util = DynamoDBUtil(table_name)

    def process_task(self, task_data):
        task_id = self._create_unique_task_id()
        self._invoke_worker_lambda(task_data, task_id)
        self.dynamodb_util.update_item(task_id, "PENDING")
        return task_id

    def _invoke_worker_lambda(self, task_data, task_id):
        try:
            payload = json.dumps({"body": {"task_id": task_id, **task_data}})
            self.lambda_client.invoke(
                FunctionName=self.worker_lambda_name,
                InvocationType="Event",
                Payload=payload
            )
            self.logger.info(f"'{self.worker_lambda_name}' invoked with payload: '{payload}'")
        except Exception as e:
            self.logger.error(f"Error invoking worker lambda: {e}")
            raise

    def check_task_status(self, task_id):
        return self.dynamodb_util.get_task_status(task_id)

    def _create_unique_task_id(self):
        while True:
            task_id = self._generate_id()
            if self._is_id_unique(task_id):
                self.logger.info(f"Task ID Generated: '{task_id}'")
                return task_id

    def _is_id_unique(self, task_id):
        task_status = self.dynamodb_util.get_task_status(task_id)
        return task_status is None

    @staticmethod
    def _generate_id():
        return str(uuid.uuid4())