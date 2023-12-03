import json
from utils.task_manager import TaskManager
from utils.response_format import ResponseFormatter

def handle(task_data, envs, mc_server, ec2_util, logger):
    logger.info("Handling 'Start' Action...")
    action = task_data["action"]

    if ec2_util.instance_exists():
        # Don't do anything if ec2 instance is about to turn off
        if ec2_util.check_instance_status() in ["Stopping", "Pending", "Shutting Down"]:
            status = "EC2_INSTANCE_SHUTTING_DOWN"
            info = f"Cannot run command as EC2 instance is still shutting down"
            task_id = None
            return status, action, task_id, info
        
        if mc_server.check()["online"]:
            status = "MC_SERVER_UP"
            info = f"Minecraft Server Already Online"
            task_id = None
            return status, action, task_id, info
        
        task_manager = TaskManager(envs["WORKER_LAMBDA_NAME"], task_data["dynambodb_table_name"])

        # Prepare Function Output
        task_id = task_manager.process_task(task_data)
        status = "PENDING"
        info = f"Started Task - ID: '{task_id}'"

        logger.info("'Start' Action Complete!")
        return status, action, task_id, info
    else:
        error_message = "EC2 Instance does not exist!"
        raise Exception(error_message)