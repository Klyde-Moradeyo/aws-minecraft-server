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
            
            # Check if task_id is present in task_data
            if 'task_id' not in task_data or task_data['task_id'] is None:
                error_message = "task_id is missing from task_data, cannot continue with request. "
                error_message += "To fix this error, include the 'task_id' in your lambda request"
                logger.error(error_message)
                task_id = None
                status = "TO_LAZY_TO_PROGRAM"
                info = f"Request Lambda Needs to be able to handle this status command scenerio"
                return status, action, task_id, info

            task_id = task_data["task_id"]
            task_manager = TaskManager(envs["WORKER_LAMBDA_NAME"], task_data["dynambodb_table_name"])
            task_status = task_manager.check_task_status(task_id)

            # Prepare Function Output
            status = task_status
            info = f"Minecraft Server being started"
            return status, action, task_id, info
        else:
            status = "MC_SERVER_DOWN"
            info = f"Minecraft Server Status - OFFLINE"
            task_id = None
            logger.info("'Handle Status' Action Complete!")
            return status, action, task_id, info
    else:
        error_message = "EC2 Instance does not exist!"
        raise Exception(error_message)