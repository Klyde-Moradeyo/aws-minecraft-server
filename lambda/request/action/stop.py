from utils.task_manager import TaskManager

def handle(task_data, envs, mc_server, ec2_util, logger):
    logger.info("Handling 'Stop' Action...")
    action = task_data["action"]

    if ec2_util.instance_exists():
        # Check if EC2 is in running state
        if ec2_util.check_instance_status() == "running":
            # Check if minecraft server is already offline
            if not mc_server.check()["online"]:
                status = "MC_SERVER_DOWN"
                info = f"Minecraft Server is already down but the ec2 instance is running?"
                task_id = None
                return status, action, task_id, info
            
            task_manager = TaskManager(envs["WORKER_LAMBDA_NAME"], task_data["dynambodb_table_name"])

            # Prepare Function Output
            task_id = task_manager.process_task(task_data)
            status = "PENDING"
            info = f"Started Task - ID: '{task_id}'"
            return status, action, task_id, info
        else:
            error_message = "EC2 Instance is not Running?"
            raise Exception(error_message)
    else:
        error_message = "EC2 Instance does not exist!"
        raise Exception(error_message)