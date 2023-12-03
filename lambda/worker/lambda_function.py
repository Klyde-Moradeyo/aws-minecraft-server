import json
import time
import shutil
import boto3
import importlib
import sys
from botocore.exceptions import BotoCoreError, ClientError
from config import *
from utils.ec2 import EC2Util
from utils.env_manager import EnvironmentVariables
from utils.event_parser import APIEventParser
from utils.fargate import Fargate
from utils.logger import setup_logging
from utils.minecraft import MinecraftServer
from utils.s3 import S3Util
from utils.ssm import SSMUtil
from utils.dynamodb import DynamoDBUtil
from utils.task_manager import TaskManager

class LambdaHandler:
    def __init__(self, event):
        # Note: May also need to add to check fargate for if the required image is in ECR.
        # Setting up logging
        self.logger = setup_logging()
        
        # Parse the event
        event_parser = APIEventParser(event)
        event_body = event_parser.parse()

        # Extract the action from the parsed event
        self.ACTION = event_body["action"] 

        # Extract other atrributes from event
        self.server_template = event_body["server_template"]
        self.task_id = event_body["task_id"]
        self.dynambodb_table_name = event_body["dynambodb_table_name"]
        self.mc_server_ip = event_body["mc_server_ip"]
        self.mc_server_port = event_body["mc_server_port"]
        self.ec2_instance_id = event_body["ec2_instance_id"]

        # Get the environment
        self.envs = EnvironmentVariables(self.ACTION).get_vars()  # Get Environment Variables

        # Initialize SSM class
        self.ssm_util = SSMUtil()

        # Initialize ec2 class
        self.ec2_util = EC2Util(self.ec2_instance_id)

        # Initialize s3 class
        self.s3_util = S3Util(self.envs, self.server_template)

        # Initialize dynamodb class
        self.dynamodb_util = DynamoDBUtil(self.dynambodb_table_name)

        # Initialize task manager class
        self.task_manager = TaskManager(self.dynambodb_table_name)

        # Check If minecraft server is online/offline
        self.mc_server = MinecraftServer(self.server_template, self.mc_server_ip, self.mc_server_port)
    
    def execute_command(self):
        try:
            # Add the 'action' directory to the system path for dynamic imports
            sys.path.append(os.path.join(os.path.dirname(__file__), 'action'))

            # Imported Action Module
            action_module = importlib.import_module(self.ACTION)

            action_module.handle(self.server_template, self.envs, self.ssm_util, self.ec2_util, self.mc_server, self.s3_util, self.logger)

            # Update DynamoDB that task completed
            self._update_task(self.task_id, "COMPLETED", "SUCCESS")
        except ImportError as import_error:
            error_message = f'Invalid action: {self.ACTION}. Error: {import_error}'
            self.logger.error(error_message)
            self._update_task(self.task_id, "ERROR", error_message)
        except ValueError as error:
            self._update_task(self.task_id, "ERROR", f"Value error occured \n{str(error)}")
        except (BotoCoreError, ClientError) as error:
            self._update_task(self.task_id, "ERROR", f"Boto3 related error occurred \n{str(error)}")
        except Exception as error:
            self._update_task(self.task_id, "ERROR", f"Unhandled exception occurred \n{str(error)}")
        
    def _update_task(self, task_id, status, result=None):
        try:
            self.task_manager.update_task_status(task_id, status)
            if result:
                self.task_manager.update_task_result(task_id, result)
        except Exception as e:
            self.logger.error(f"Failed to update task_id: {task_id} \n{e}")
            raise

# Where the magic happens
def lambda_handler(event, context):
    # Remove git repo if present
    if os.path.exists(GIT_REPO_PATH) and os.listdir(GIT_REPO_PATH):
        shutil.rmtree(GIT_REPO_PATH)
        os.makedirs(GIT_REPO_PATH)

    handler = LambdaHandler(event)
    return handler.execute_command()
