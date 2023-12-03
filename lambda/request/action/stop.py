from utils.task_manager import TaskManager

def handle(task_data, mc_server_status, ec2_util, dynambodb_table_name, logger):
    if ec2_util.instance_exists():
        if ec2_util.check_instance_status() == "running":
            if not mc_server_status["online"]:
                return {"STATUS": "MC_SERVER_DOWN", "COMMAND": task_data["action"], "INFO": "Minecraft Server is already down"}
            
            task_manager = TaskManager(dynambodb_table_name)

            # Prepare Function Output
            task_id = task_manager.process_task(task_data)
            status = "PENDING"
            action = task_data["action"]
            info = f"Started Task - ID: '{task_id}'"
            return status, action, task_id, info
        else:
            error_message = "EC2 Instance is not Running?"
            raise Exception(error_message)
    else:
        error_message = "EC2 Instance does not exist!"
        raise Exception(error_message)