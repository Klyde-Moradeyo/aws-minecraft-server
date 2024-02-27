from config import *
from utils.ssh import SSHUtil
from utils.ssm import SSMUtil
from utils.ec2 import EC2Util
from utils.minecraft import MinecraftServer
from utils.s3 import S3Util
from config import *

def handle(event_body, envs, ssm_util: SSMUtil, ec2_util: EC2Util, mc_server: MinecraftServer, s3_util: S3Util, logger):
    logger.info("Handling 'Restart' Action...")
    status = None
    info = None

    # Establish connection to Ec2 instance
    ssh_key_str = ssm_util.get_param(envs["SSM_GIT_PRIVATE_KEY"])             
    ec2_ssh_key_path = ec2_util.write_ec2_ssh_key_to_file(ssm_util.get_param(envs["SSM_EC2_PRIVATE_KEY"]))
    ssh_util = SSHUtil(event_body["mc_server_ip"], EC2_USERNAME, ec2_ssh_key_path)

    # Shutdown minecraft server
    if ssh_util.file_exists(REMOTE_DOCKER_COMPOSE_PATH):
        # Restart minecraft server
        ssh_util.run_command(f"cd {REMOTE_SERVER_FOLDER_PATH} && sudo docker compose restart mc-server")
        logger.info("Restarted Minecraft Server!")

        status = "MC_SERVER_RESTART_COMPLETE"
        info = "EC2 Instance was restarted Successfully"
    else:
        error_message = f"Could not restart containers. No docker-compose yaml found in '{REMOTE_DOCKER_COMPOSE_PATH}'"
        raise Exception(error_message)

    return status, info
