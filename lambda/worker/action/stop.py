import json
from utils.ssh import SSHUtil
from utils.git import GitUtil
from utils.ssm import SSMUtil
from utils.ec2 import EC2Util
from utils.file_handler import write_to_tmp_file, generate_env_file, JSONHelper
from utils.minecraft import MinecraftServer
from utils.s3 import S3Util
from config import *

def handle(event_body, envs, ssm_util: SSMUtil, ec2_util: EC2Util, mc_server: MinecraftServer, s3_util: S3Util, logger):
    logger.info("Handling 'Stop' Action...")
    status = None
    info = None

    # Establish connection to Ec2 instance
    ssh_key_str = ssm_util.get_param(envs["SSM_GIT_PRIVATE_KEY"])             
    ec2_ssh_key_path = ec2_util.write_ec2_ssh_key_to_file(ssm_util.get_param(envs["SSM_EC2_PRIVATE_KEY"]))
    ssh_util = SSHUtil(event_body["mc_server_ip"], EC2_USERNAME, ec2_ssh_key_path)

    # Shutdown minecraft server
    ssh_util.run_command(f"cd {REMOTE_SERVER_FOLDER_PATH} && sudo docker compose down")
    logger.info("Stopped all EC2 containers")

    # Clone Git Repo
    git_ssh_key_path = write_to_tmp_file(ssh_key_str)
    git_util = GitUtil(git_ssh_key_path)
    git_util.clone(GIT_REPO_URL, GIT_REPO_PATH, envs["GIT_BRANCH"])

    # Get Server Template
    server_template = ssh_util.read_file_output(REMOTE_TEMPLATE_INFO_FILE_PATH)
    mc_server.update_server_template(server_template)
    s3_util.update_server_template(server_template)

    # Delete Datapack folder from world folder
    ssh_util.run_command(f"rm -rfv {NEW_REMOTE_MINECRAFT_DATAPACK_PATH}")

    # Back up the world to S3 Bucket
    world_save_enabled_str = mc_server.get_server_config(LOCAL_BASE_CONFIG_PATH, LOCAL_TEMPLATE_CONFIG_PATH).get("SAVE_MINECRAFT_WORLD").lower()
    world_save_enabled = world_save_enabled_str == 'true'
    if world_save_enabled:
        ssh_util.run_command(f"aws s3 cp '{REMOTE_MINECRAFT_WORLD_PATH}' '{s3_util.get_minecraft_world_path()}' --recursive")
        logger.info("Successfully Backed Up Minecraft World")
    else:
        logger.info("World save is disabled...Skipping.")

    # Delete all files from the ec2 machine excluding the scripts logs folder
    # Note: this doesn't work as intended. Just purges everything
    ssh_util.run_command(f"find '{REMOTE_SERVER_FOLDER_PATH}' -path '{REMOTE_SCRIPT_LOGS_PATH}' -prune -o -print0 | xargs -0 rm -rf")
    logger.info("Successfully Deleted Workspace")

    # Stop EC2 instance
    ec2_util.stop_instance()
    
    status = "MC_SERVER_STOPPED"
    info = "Stopped Minecraft Server Successfully"
    logger.info("'Stop' Action Complete!")
    return status, info