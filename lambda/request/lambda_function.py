import json
import os
import sys
import importlib
from boto3.dynamodb.conditions import Key
from utils.logger import setup_logging
from utils.event_parser import APIEventParser
from utils.env_manager import EnvironmentVariables
from utils.ec2 import EC2Util
from utils.minecraft import MinecraftServer
from utils.response_format import ResponseFormatter

def lambda_handler(event, context):
    try:
        # Initialize variables
        status = None
        task_id = None
        info = None

        logger = setup_logging()
        
        # Parse the event
        event_parser = APIEventParser(event)
        event_body = event_parser.parse()
        action = event_body["action"] 
        logger.info("Parsed Lambda Event")

        # Get the environment vars
        envs = EnvironmentVariables(action).get_vars()
        ec2_instance_id = envs["EC2_INSTANCE_ID"]
        dynambodb_table_name = envs["DYNAMO_DB_TABLE_NAME"]
        minecraft_server_ip = envs["MC_SERVER_IP"]
        minecraft_server_port = envs["MC_PORT"]

        # Initialize ec2 class
        ec2_util = EC2Util(ec2_instance_id)

        # Add the 'action' directory to the system path for dynamic imports
        sys.path.append(os.path.join(os.path.dirname(__file__), 'action'))

        # Imported Action Module
        action_module = importlib.import_module(action)

        # Check If minecraft server is online/offline  
        mc_server = MinecraftServer(minecraft_server_ip, minecraft_server_port)

        # Add new data to task_data
        task_data = event_body
        task_data["ec2_instance_id"] = ec2_instance_id
        task_data["dynambodb_table_name"] = dynambodb_table_name
        task_data["mc_server_ip"] = minecraft_server_ip
        task_data["mc_server_port"] = minecraft_server_port
        logger.info(f"Task Data: {task_data}")

        # Call the action handler function
        status, action, task_id, info = action_module.handle(event_body, envs, mc_server, ec2_util, logger)
        logger.info(f"STATUS: {status} | ACTION: {action} | TASK_ID: {task_id} | INFO: {info}")
        return {
            'statusCode': 200,
            'body': json.dumps(ResponseFormatter.success_response(status, action, task_id, info))
        }
    except ImportError as import_error:
        error_message = f'Invalid action: {action}. Error: {import_error}'
        logger.error(error_message)
        return {
            'statusCode': 400,
            'body': json.dumps(ResponseFormatter.error_response("ERROR", "Invalid Action", None, None, error_message))
        }
    except Exception as e:
        error_message = f'Server Error: {str(e)}'
        logger.error(error_message)
        return {
            'statusCode': 500,
            'body': json.dumps(ResponseFormatter.error_response(status, action, task_id, info, error_message))
        }
