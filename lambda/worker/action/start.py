import json
from utils.ssh import SSHUtil
from utils.git import GitUtil
from utils.ssm import SSMUtil
from utils.ec2 import EC2Util
from utils.file_handler import write_to_tmp_file, generate_env_file, JSONHelper
from utils.minecraft import MinecraftServer
from utils.s3 import S3Util
from config import *

def get_packages_install(ssh):
    """
    Function to check check installtions in remote machine
    """
    packages_installed = { 
        "docker": ssh.is_installed("docker", "docker -v"),
        "docker-compose": ssh.is_installed("docker-compose", "docker compose version"),
        "git": ssh.is_installed("git", "git --version"),
        "aws-cli": ssh.is_installed("aws-cli", "aws --version")
    }
    return packages_installed

def handle(event_body, envs, ssm_util: SSMUtil, ec2_util: EC2Util, mc_server: MinecraftServer, s3_util: S3Util, logger):
    logger.info("Handling 'Start' Action...")
    status = None
    info = None

    # Get Server Template
    server_template = event_body["server_template"]

    ssh_key_str = ssm_util.get_param(envs["SSM_GIT_PRIVATE_KEY"])
    git_ssh_key_path = write_to_tmp_file(ssh_key_str)

    git_util = GitUtil(git_ssh_key_path)
    git_util.clone(GIT_REPO_URL, GIT_REPO_PATH, envs["GIT_BRANCH"])

    # Check if Template is valid
    config = JSONHelper.read_json(LOCAL_TEMPLATE_CONFIG_PATH)
    if server_template not in config.get("templates", {}):
        error_message = f"Template '{server_template}' is not found in the configuration. Cannot start MC Server."
        raise Exception(error_message)
    
    # Start EC2 instance
    ec2_util.start_instance()

    # Create SSH Connection
    ec2_ssh_key_path = ec2_util.write_ec2_ssh_key_to_file(ssm_util.get_param(envs["SSM_EC2_PRIVATE_KEY"]))
    ssh_util = SSHUtil(mc_server.get_server_ip(), EC2_USERNAME, ec2_ssh_key_path)

    # Copy Latest Sever Folder to ec2 machine
    ssh_util.scp_to_machine(LOCAL_SERVER_FOLDER_PATH, REMOTE_SERVER_FOLDER_PATH)

    # If there are missing packages, install them
    packages_installed = get_packages_install(ssh_util)
    logger.info(f"Packages Installed: {packages_installed}")
    if not all(packages_installed.values()):
        logger.info("Packages missing: Executing Install script...")
        ssh_util.run_command(f"chmod -R +x {REMOTE_SCRIPT_PATH}/*.sh")
        ssh_util.run_script(REMOTE_PREPARE_EC2_SCRIPT_PATH, REMOTE_PREPARE_EC2_LOGS_PATH, True)
        status = "EC2_INSTALL_STARTED"
        info = "Started EC2 Install Script"
        return status, info

    # Define map for additonal configs
    additional_configs = {}

    # Set Minecraft Server Port
    additional_configs["SERVER_PORT"] = mc_server.get_server_port()

    # Copy the current template id to a file on the ec2 machine
    template_id_file = write_to_tmp_file(server_template)
    ssh_util.scp_to_machine(template_id_file, REMOTE_TEMPLATE_INFO_FILE_PATH)

    # Copy S3 minecraft world to ec2 machine if exist 
    # Look into using boto3 for this
    s3_mc_world_path = s3_util.get_minecraft_world_path()
    try:
        s3_ls_output = ssh_util.run_command(f"aws s3 ls '{s3_mc_world_path}/'", capture_output=True)
    except Exception as e:
        s3_ls_output = None
        logger.warn(f"Error retrieving '{s3_mc_world_path}' Maybe the S3 Path doesn't exist? Continuing...")

    if s3_ls_output:
        ssh_util.run_command(f"aws s3 cp '{s3_mc_world_path}' '{REMOTE_MINECRAFT_WORLD_PATH}' --recursive")
        additional_configs["WORLD"] = CONTAINER_MINECRAFT_WORLD_PATH # Add world to config
        logger.info("Successfully Restored S3 Minecraft World")
    else:
        # Enable Permisions to the minecraft folder for first time run - Required since mc-exporters uses world dir of mc-server container
        ssh_util.run_command(f"mkdir -p {REMOTE_MINECRAFT_WORLD_PATH}")
        ssh_util.run_command(f"chmod 777 -R {REMOTE_MINECRAFT_WORLD_PATH}")

    # Copy minecraft server mod config files to EC2 if exist 
    s3_mod_config_path = s3_util.get_server_mods_path()
    try:
        s3_ls_output = ssh_util.run_command(f"aws s3 ls '{s3_mod_config_path}/'", capture_output=True)
    except Exception as e:
        s3_ls_output = None
        logger.warn(f"Error retrieving '{s3_mod_config_path}' Maybe the S3 Path doesn't exist? Continuing...")

    if s3_ls_output:
        ssh_util.run_command(f"aws s3 cp '{s3_mod_config_path}' '{REMOTE_MINECRAFT_SERVER_PATH}' --recursive")
        logger.info("Successfully Restored S3 Mod Config")
    
    # Calculcate Minecraft Server's available memory
    additional_configs["MEMORY"] = mc_server.get_memory(ssh_util)

    # Select the server's icon
    additional_configs["ICON"] = mc_server.select_icon()

    # Configure RCON
    additional_configs["RCON_PORT"] = RCON_PORT
    additional_configs["RCON_PASSWORD"] = mc_server.generate_rcon_password(24)

    # Generate Server Config and Copy to Remote machine
    server_config = mc_server.initialize_server_config(LOCAL_BASE_CONFIG_PATH, LOCAL_TEMPLATE_CONFIG_PATH, additional_configs)
    ssh_util.scp_to_machine(server_config, REMOTE_MC_SERVER_ENV_FILE_PATH)

    # Generate Monitoring Config and Copy to Remote machine
    monitor_config = { 
        "RCON_HOST": "mc-server",
        "RCON_PORT": additional_configs["RCON_PORT"], 
        "RCON_PASSWORD": additional_configs["RCON_PASSWORD"],
        "DYNMAP_ENABLED": "True",
        "API_GW_URL": envs["API_GW_URL"],
        "SSM_API_KEY": envs["SSM_REQUEST_LAMBDA_AUTH_TOKEN"],
        "PROMETHEUS_PORT": None,
    }
    monitor_config = generate_env_file(monitor_config)
    ssh_util.scp_to_machine(monitor_config, REMOTE_MC_MONITOR_ENV_FILE_PATH)


    # Start docker compose from server folder
    if ssh_util.file_exists(REMOTE_DOCKER_COMPOSE_PATH):
        ssh_util.run_command(f"cd {REMOTE_SERVER_FOLDER_PATH} && sudo docker compose up -d --build")
        logger.info("Started Minecraft Server!")
    else:
        error_message = f"Could not start containers. No docker-compose yaml found in '{REMOTE_DOCKER_COMPOSE_PATH}'"
        raise Exception(error_message)
    
    status = "MC_SERVER_STARTED"
    info = "Started Minecraft Server Successfully"
    logger.info("'Start' Action Complete!")
    return status, info
