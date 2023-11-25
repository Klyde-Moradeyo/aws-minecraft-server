import json
import time
import boto3
from botocore.exceptions import BotoCoreError, ClientError
from config import *
from utils.ec2 import EC2Util
from utils.env_manager import EnvironmentVariables
from utils.event_parser import APIEventParser
from utils.fargate import Fargate
from utils.file_handler import write_to_tmp_file, generate_env_file, JSONHelper
from utils.git import GitUtil
from utils.logger import setup_logging
from utils.minecraft import MinecraftServer
from utils.s3 import S3Util
from utils.ssh import SSHUtil
from utils.ssm import SSMUtil
from utils.time_utils import seconds_to_minutes, DateTimeEncoder


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
        self.server_template = event_body["server_template"]

        # Get the environment
        self.envs = EnvironmentVariables(self.ACTION).get_vars()  # Get Environment Variables

        # Initialize SSM class
        self.ssm = SSMUtil()

        # Initialize ec2 class
        self.ec2_util = EC2Util(self.envs["EC2_INSTANCE_ID"], self.envs)
        self.s3_util = S3Util(self.envs, self.server_template)

        # Check If minecraft server is online/offline
        self.mc_server = MinecraftServer(self.server_template, self.envs["MC_SERVER_IP"], self.envs["MC_PORT"])
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
            elif self.ACTION == "start":
                response = self.handle_start()
            elif self.ACTION == "stop":
                response = self.handle_stop()
            elif self.ACTION == "status":
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
        # Function to check check installtions in remote machine
        def get_packages_install(ssh):
            packages_installed = { 
                "docker": ssh.is_installed("docker", "docker -v"),
                "docker-compose": ssh.is_installed("docker-compose", "docker compose version"),
                "git": ssh.is_installed("git", "git --version"),
                "aws-cli": ssh.is_installed("aws-cli", "aws --version")
            }
            self.logger.info(f"Packages Installed: {packages_installed}")
            return packages_installed
        
        if self.mc_server_status["online"]:
            return {"STATUS": "MC_SERVER_UP", "COMMAND": self.ACTION, "INFO": "MINECRAFT SERVER ALREADY ONLINE"}

        ssh_key_str = self.ssm.get_param(self.envs["SSM_GIT_PRIVATE_KEY"])
        git_ssh_key_path = write_to_tmp_file(ssh_key_str)

        git_util = GitUtil(git_ssh_key_path)
        git_util.clone(GIT_REPO_URL, GIT_REPO_NAME, self.envs["GIT_BRANCH"])

        # Check if Template is valid
        self.config = JSONHelper.read_json(LOCAL_TEMPLATE_CONFIG_PATH)
        if self.server_template not in self.config.get("templates", {}):
            error_message = f"Template '{self.server_template}' is not found in the configuration. Cannot start MC Server."
            raise Exception(error_message)

        if self.ec2_util.instance_exists():
            # Start EC2 instance
            self.ec2_util.start_instance()

            # Create SSH Connection
            ec2_ssh_key_path = self.ec2_util.write_ec2_ssh_key_to_file(self.ssm.get_param(self.envs["SSM_EC2_PRIVATE_KEY"]))
            self.ssh_util = SSHUtil(self.envs["MC_SERVER_IP"], EC2_USERNAME, ec2_ssh_key_path)

            # Copy Latest Sever Folder to ec2 machine
            self.ssh_util.scp_to_machine(LOCAL_SERVER_FOLDER_PATH, REMOTE_SERVER_FOLDER_PATH)

            # If there are missing packages, install them
            if not all(get_packages_install(self.ssh_util).values()):
                self.logger.info("Packages missing: Executing Install script...")
                # Run install script
                self.ssh_util.run_script(REMOTE_INSTALL_SCRIPT_PATH, REMOTE_INSTALL_LOGS_PATH)

                # Check if install script was successful
                packages_installed = get_packages_install(self.ssh_util).values()
                if not packages_installed:
                    # Identify which packages failed to install
                    failed_packages = [pkg for pkg, installed in packages_installed.items() if not installed]
                    error_message = f"Failed to install packages: {', '.join(failed_packages)}"
                    raise Exception(error_message)
                
            # Define map for additonal configs
            additional_configs = {}

            # Copy .current_template to ec2 machine
            template_id_file = write_to_tmp_file(self.server_template)
            self.ssh_util.scp_to_machine(template_id_file, REMOTE_TEMPLATE_INFO_FILE_PATH)
        
            # Copy S3 minecraft world to ec2 machine if exist 
            # Look into using boto3 for this
            s3_mc_world_path = self.s3_util.get_minecraft_world_path()
            try:
                s3_ls_output = self.ssh_util.run_command(f"aws s3 ls '{s3_mc_world_path}/'", capture_output=True)
            except Exception as e:
                s3_ls_output = None
                self.logger.warn(f"Error retrieving '{s3_mc_world_path}' Maybe the S3 Path doesn't exist? Continuing...")

            if s3_ls_output:
                self.ssh_util.run_command(f"aws s3 cp '{s3_mc_world_path}' '{REMOTE_MINECRAFT_WORLD_PATH}' --recursive")
                additional_configs["WORLD"] = CONTAINER_MINECRAFT_WORLD_PATH # Add world to config
                self.logger.info("Successfully Restored S3 Minecraft World")

            # Copy minecraft server mod config files to EC2 if exist 
            s3_mod_config_path = self.s3_util.get_server_mods_path()
            try:
                s3_ls_output = self.ssh_util.run_command(f"aws s3 ls '{s3_mod_config_path}/'", capture_output=True)
            except Exception as e:
                s3_ls_output = None
                self.logger.warn(f"Error retrieving '{s3_mod_config_path}' Maybe the S3 Path doesn't exist? Continuing...")

            if s3_ls_output:
                self.ssh_util.run_command(f"aws s3 cp '{s3_mod_config_path}' '{REMOTE_MINECRAFT_SERVER_PATH}' --recursive")
                self.logger.info("Successfully Restored S3 Mod Config")
            
            # Calculcate Minecraft Server's available memory
            additional_configs["MEMORY"] = self.mc_server.get_memory(self.ssh_util)

            # Select the server's icon
            additional_configs["ICON"] = self.mc_server.select_icon()

            # Configure RCON
            additional_configs["RCON_PORT"] = RCON_PORT
            additional_configs["RCON_PASS"] = self.mc_server.generate_rcon_password(24)

            # Generate Server Config and Copy to Remote machine
            server_config = self.mc_server.initialize_server_config(LOCAL_BASE_CONFIG_PATH, LOCAL_TEMPLATE_CONFIG_PATH, additional_configs)
            self.ssh_util.scp_to_machine(server_config, REMOTE_MC_SERVER_ENV_FILE_PATH)

            # Generate Monitoring Config and Copy to Remote machine
            monitor_config = { 
                "RCON_PORT": additional_configs["RCON_PORT"], 
                "RCON_PASS": additional_configs["RCON_PASS"],
                "API_GW_URL": self.envs["API_GW_URL"],
                "SSM_API_KEY": self.envs["SSM_API_KEY"],
                "PROMETHEUS_PORT": None,
            }
            monitor_config = generate_env_file(monitor_config)
            self.ssh_util.scp_to_machine(monitor_config, REMOTE_MC_MONITOR_ENV_FILE_PATH)

            # Start docker compose from server folder
            if self.ssh_util.file_exists(REMOTE_DOCKER_COMPOSE_PATH):
                self.ssh_util.run_command(f"cd {REMOTE_SERVER_FOLDER_PATH} && sudo docker compose up -d --build")
                self.logger.info("Started Minecraft Server!")
            else:
                error_message = f"Could not start containers. No docker-compose yaml found in '{REMOTE_DOCKER_COMPOSE_PATH}'"
                raise Exception(error_message)

            return { 'STATUS': "MC_SERVER_STARTED", 'COMMAND': self.ACTION, "INFO": "STARTED MINECRAFT SERVER SUCCESSFULLY" }
        else:
            error_message = "EC2 Instance does not exist!"
            raise Exception(error_message)
            
    def handle_stop(self):
        if self.ec2_util.instance_exists():
            if self.ec2_util.check_instance_status() == "running":
                # Check if minecraft server is already offline
                if not self.mc_server_status["online"]:
                    return {"STATUS": "MC_SERVER_DOWN", "COMMAND": self.ACTION, "INFO": "MINECRAFT SERVER ALREADY OFFLINE"}
                
                # Establish connection to Ec2 instance
                ssh_key_str = self.ssm.get_param(self.envs["SSM_GIT_PRIVATE_KEY"])             
                ec2_ssh_key_path = self.ec2_util.write_ec2_ssh_key_to_file(self.ssm.get_param(self.envs["SSM_EC2_PRIVATE_KEY"]))
                self.ssh_util = SSHUtil(self.envs["MC_SERVER_IP"], EC2_USERNAME, ec2_ssh_key_path)

                # Shutdown minecraft server
                self.ssh_util.run_command(f"cd {REMOTE_SERVER_FOLDER_PATH} && sudo docker compose down")
                self.logger.info("Stopped all EC2 containers")

                # Clone Git Repo
                git_ssh_key_path = write_to_tmp_file(ssh_key_str)
                git_util = GitUtil(git_ssh_key_path)
                git_util.clone(GIT_REPO_URL, GIT_REPO_NAME, self.envs["GIT_BRANCH"])

                # Back up the world to S3 Bucket
                world_save_enabled_str = self.mc_server.get_server_config(LOCAL_BASE_CONFIG_PATH, LOCAL_TEMPLATE_CONFIG_PATH).get("SAVE_MINECRAFT_WORLD").lower()
                world_save_enabled = world_save_enabled_str == 'true'
                if world_save_enabled:
                    self.ssh_util.run_command(f"aws s3 cp '{REMOTE_MINECRAFT_WORLD_PATH}' '{self.s3_util.get_minecraft_world_path()}' --recursive")
                    self.logger.info("Successfully Backed Up Minecraft World")
                else:
                    self.logger.info("World save is disabled...Skipping.")

                # Delete all files from the ec2 machine excluding the scripts logs folder
                # Note: this doesn't work as intended. Just purges everything
                self.ssh_util.run_command(f"find '{REMOTE_SERVER_FOLDER_PATH}' -path '{REMOTE_SCRIPT_LOGS_PATH}' -prune -o -print0 | xargs -0 rm -rf")
                self.logger.info("Successfully Deleted Workspace")

                # Stop EC2 instance
                self.ec2_util.stop_instance()
                return { 'STATUS': "MC_SERVER_STOPPED", 'COMMAND': self.ACTION, "INFO": "STOPPED MINECRAFT SERVER" } 
            else:
                error_message = "EC2 Instance is not Running?"
                raise Exception(error_message)
        else:
            error_message = "EC2 Instance does not exist!"
            raise Exception(error_message)

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
        if self.ec2_util.instance_exists():
            if self.ec2_util.check_instance_status() == "running":
                if self.mc_server_status["online"]:
                    return { 'STATUS': "MC_SERVER_UP", 'COMMAND': self.ACTION, "INFO": "RETRIEVED MINECRAFT SERVER STATUS"}
                else:
                    return { 'STATUS': "PROVISIONING", 'COMMAND': self.ACTION, "INFO": "RETRIEVED MINECRAFT SERVER STATUS"}
            else:
                return { 'STATUS': "MC_SERVER_DOWN", 'COMMAND': self.ACTION, "INFO": "RETRIEVED MINECRAFT SERVER STATUS"}
        else:
            error_message = "EC2 Instance does not exist!"
            raise Exception(error_message)

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