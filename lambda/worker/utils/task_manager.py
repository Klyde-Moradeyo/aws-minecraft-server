import uuid
import json
import os
import boto3
from datetime import datetime
from .logger import setup_logging
from utils.dynamodb import DynamoDBUtil

class TaskManager:
    def __init__(self, dynamodb_util: DynamoDBUtil):
        self.logger = setup_logging()
        self.dynamodb_util = dynamodb_util

    def update_task_status(self, task_id, value):
        try:
            self.dynamodb_util.update_task_attribute(task_id, "status", value)
        except Exception as e:
            self.logger.error(f"Failed to update task_id('{task_id}') with status: '{value}' \n{e}")

    def update_task_result(self, task_id, value):
        try:
            self.dynamodb_util.update_task_attribute(task_id, "result", value)
        except Exception as e:
            self.logger.error(f"Failed to update task_id('{task_id}') with result: '{value}' \n{e}")