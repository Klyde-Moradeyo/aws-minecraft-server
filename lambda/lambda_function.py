import boto3
import time
import json
from config import *
from botocore.exceptions import BotoCoreError, ClientError
from utils.event_parser import APIEventParser
from utils.env_manager import EnvironmentVariables
from utils.minecraft import MinecraftServer
from utils.fargate import Fargate
from utils.time_utils import seconds_to_minutes, DateTimeEncoder
from utils.ssm import SSMUtil
from utils.ec2 import EC2Util
from utils.ssh import SSHUtil
from utils.file_handler import write_to_tmp_file
from utils.git import GitUtil
from utils.logger import setup_logging

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
        self.logger.info(f"Running Action: {self.ACTION}")

        # Get the environment
        self.envs = EnvironmentVariables(self.ACTION).get_vars()  # Get Environment Variables

        # Initialize SSM class
        self.ssm = SSMUtil()

        # Initialize ec2 class
        self.ec2_util = EC2Util(self.envs["EC2_INSTANCE_ID"], self.envs)

        # Check If minecraft server is online/offline
        self.mc_server = MinecraftServer(self.envs["MC_SERVER_IP"], self.envs["MC_PORT"])
        self.mc_server_status = self.mc_server.check()
    
    def execute_command(self):
        try:
            if self.ACTION == "PING":
                response = self.handle_ping()
            # elif self.ACTION == "mc_world_archive":
            #     # Initialize Fargate class
            #     # Perform checks
            #     self.mc_server_status = MinecraftServer(self.envs["MC_SERVER_IP"], self.envs["MC_PORT"]).check()  # Check If minecraft server is online/offline
            #     self.is_task_running = self.tec_fargate.is_task_with_tags_exists(self.task_tags)  # Check if there's a Fargate task running
            #     self.tec_fargate = Fargate(self.envs['CLUSTER'], self.envs)  # TEC means Terraform Execution Container
            #     self.task_tags = self.tec_fargate.get_task_tags()
            #     response = self.handle_mc_world_archive()
            elif self.ACTION == 'start':
                response = self.handle_start()
            elif self.ACTION == 'stop':
                response = self.handle_stop()
            elif self.ACTION == 'status':
                response = self.handle_server_status()
            else:
                raise ValueError(f"Invalid command: {self.ACTION}")
            
            return {
                "statusCode": 200,
                "body": json.dumps(response, cls=DateTimeEncoder)
            }
        except ValueError as error:
            self.logger.error("Value error occurred", extra={"error": str(error)})
            return {
                "statusCode": 400,
                "body": json.dumps({"error": str(error)}, cls=DateTimeEncoder)
            }
        except (BotoCoreError, ClientError) as error:
            self.logger.exception("Boto3 related error occurred", extra={"error": str(error)})
            return {
                "statusCode": 500,
                "body": json.dumps({"error": str(error)}, cls=DateTimeEncoder)
            }
        except Exception as error:
            self.logger.exception("Unhandled exception occurred", extra={"error": str(error)})
            return {
                "statusCode": 500,
                "body": json.dumps({"error": str(error)}, cls=DateTimeEncoder)
            }
        
    def handle_start(self):
        if self.mc_server_status["online"]:
            return {"STATUS": "MC_SERVER_UP", "COMMAND": self.ACTION, "INFO": "MINECRAFT SERVER ALREADY ONLINE"}

        ssh_key_str = self.ssm.get_param(self.envs["SSM_GIT_PRIVATE_KEY"])
        git_ssh_key_path = write_to_tmp_file(ssh_key_str)

        git_util = GitUtil(git_ssh_key_path)
        git_util.clone(GIT_REPO_URL, GIT_REPO_NAME, self.envs["GIT_BRANCH"])

        if self.ec2_util.instance_exists():
            self.ec2_util.start_instance()

            ec2_ssh_key_path = self.ec2_util.write_ec2_ssh_key_to_file(self.ssm.get_param(self.envs["SSM_EC2_PRIVATE_KEY"]))
            self.ssh_util = SSHUtil(self.envs["MC_SERVER_IP"], EC2_USERNAME, ec2_ssh_key_path)

            # Copy Latest Sever Folder to ec2 machine
            self.ssh_util.scp_to_machine(LOCAL_SERVER_FOLDER_PATH, REMOTE_SERVER_FOLDER_PATH)

            packages_installed = { 
                "docker": self.ssh_util.is_installed("docker", "docker -v"),
                "docker-compose": self.ssh_util.is_installed("docker-compose", "docker compose version"),
                "git": self.ssh_util.is_installed("git", "git --version"),
                "aws-cli": self.ssh_util.is_installed("aws-cli", "aws --version")
            }

            self.logger.info(f"Packages Installed: {packages_installed}")

            # If there are missing packages, install them
            if not all(packages_installed.values()):
                self.logger.info("Packages missing: Executing Install script...")
                # Run install script
                self.ssh_util.run_script(REMOTE_INSTALL_SCRIPT_PATH, REMOTE_INSTALL_LOGS_PATH)
                packages_installed = { 
                    "docker": self.ssh_util.is_installed("docker", "docker -v"),
                    "docker-compose": self.ssh_util.is_installed("docker-compose", "docker compose version"),
                    "git": self.ssh_util.is_installed("git", "git --version"),
                    "aws-cli": self.ssh_util.is_installed("aws-cli", "aws --version")
                }
                self.logger.info(f"Packages Installed: {packages_installed}")

                # Check if install script was successful
                if not all(packages_installed.values()):
                    return "error!!!!!!!!!!!!"

            # SSH and start docker compose containers

            if "ec2_status" == "RUNNING":
                return { 'STATUS': "ec2_status", 'COMMAND': self.ACTION, "INFO": "STARTED MINECRAFT SERVER SUCCESSFULLY" }
            else:
                return { 'STATUS': "ec2_status", 'COMMAND': self.ACTION, "INFO": "STARTED MINECRAFT SERVER SUCCESSFULLY" }
            

    def handle_stop(self):
        # if not self.mc_server_status["online"]:
        #     return {"STATUS": "MC_SERVER_DOWN", "COMMAND": self.ACTION, "INFO": "MINECRAFT SERVER ALREADY OFFLINE"}
        
        # Check if EC2 instance is in running state 
                    # if running -> Check if minecraft server is online 
                                # -> if online: ssh into the machine and backup the filesd
                                # -> if offline: notify user and admin that an error has occured
                    # if stopped -> infrom user that it has already been stopped
        return


    def handle_server_backup_status(self):
        if self.is_task_running:
            task_status = self.tec_fargate.check_task_status(self.task_tags)
        else:
            if self.mc_server_status["online"]:
                task_status = "MC_SERVER_UP"
            else:
                task_status = "MC_SERVER_DOWN"

        prev_command = self.ssm.get_param(self.envs["BOT_COMMAND_NAME"])
        return { 'STATUS': task_status, 'COMMAND': prev_command, "INFO": "RETRIEVED MINECRAFT SERVER STATUS"}
    
    def handle_server_status(self):
        # Check if ec2 is running
            # if it is running: 
                    # -> Check if minecraft server is online
                            # if mc server online -> inform user that it is online
                            # if mc server offline -> check other container's health in the machine and then -> notify user and admin that an error has occured (admin gets more info through dm)
            # if it is stopped:
                    # inform user that it has stopped
        return

    def handle_mc_world_archive(self):
        """
        Handle Minecraft world archive tasks. Wait for any running task to finish, then launch a new Fargate task.
        """
        def launch_new_fargate_task(self):
            """
            Launch a new Fargate task and return its status.
            """
            self.ssm.send_param(self.ACTION, "String", self.envs["BOT_COMMAND_NAME"])

            # Launch Fargate Container
            task_arn = self.tec_fargate.create_fargate_container()
            self.logger.info(f"New Fargate task launched: {task_arn}")

            # Confirm the task i running
            task_status = self.tec_fargate.check_task_status(self.task_tags)
            if task_status is None:
                raise Exception(f"Error running Starting Task: {task_arn}")
            
            return task_arn, task_status
        
        task_name = "MC_WORLD_ARCHIVE"
        # If a task is currently running, wait for it to finish up to a time limit
        if self.is_task_running:
            check_interval = 60
            time_limit = 600
            start_time = time.time()
            self.logger.info(f"waiting for {seconds_to_minutes(time_limit)} minutes")

            while (time.time() - start_time) < time_limit:
                self.is_task_running = self.tec_fargate.is_task_with_tags_exists(self.task_tags)
                if not self.is_task_running:
                    task_arn, task_status = launch_new_fargate_task()
                    return { "STATUS": task_name, "INFO": f"New Fargate task launched: {task_arn} | {task_status}" }

                time.sleep(check_interval)
                elapsed = time.time() - start_time
                self.logger.info(f"time elapsed: {int(elapsed)} seconds")

            self.logger.warning(f"Fargate task still running after {seconds_to_minutes(elapsed)} minutes.")
            return { "STATUS": f"MC_WORLD_ARCHIVE_FAILED_START", "INFO": f"Timed out" }
        
        # If no task is running, directly launch a new one
        launch_new_fargate_task()
        return { "STATUS": task_name, 'COMMAND': self.ACTION, "INFO": f"New Fargate task launched: {task_arn} | {task_status}" }
    
    def handle_ping(self):
        self.logger.info("Testing Lambda with PING - PONG")
        return { "STATUS": "PONG", "COMMAND": self.ACTION, "INFO": "Testing Lambda with PING - PONG" }


# Where the magic happens
def lambda_handler(event, context):
    handler = LambdaHandler(event)
    return handler.execute_command()

event = {
"body": "{\"action\": \"start\"}"
}
context=None
print(lambda_handler(event, context))

 