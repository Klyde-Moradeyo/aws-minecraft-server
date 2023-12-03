from utils.task_manager import TaskManager

def handle(task_data, envs, mc_server, ec2_util, logger):
    logger.info("Handling 'Server Status' Action...")
    action = task_data["action"]

    if ec2_util.instance_exists():
        if ec2_util.check_instance_status() == "running":
            if mc_server.check()["online"]:
                status = "MC_SERVER_UP"
                info = f"Minecraft Server Status - ONLINE"
                task_id = None
                return status, action, task_id, info

            task_id = task_data["task_id"]
            task_manager = TaskManager(envs["WORKER_LAMBDA_NAME"], task_data["dynambodb_table_name"])
            task_status = task_manager.check_task_status(task_id)

            # Prepare Function Output
            status = task_status
            info = f"Minecraft Server being started"
            return status, action, task_id, info
        else:
            return { 'STATUS': "MC_SERVER_DOWN", 'COMMAND': task_data["action"], "INFO": "Minecraft Server Status - OFFLINE"}
    else:
        error_message = "EC2 Instance does not exist!"
        raise Exception(error_message)