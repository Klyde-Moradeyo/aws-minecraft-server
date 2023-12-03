from utils.task_manager import TaskManager

def handle(task_data, mc_server_status, ec2_util, dynambodb_table_name, logger):
    if ec2_util.instance_exists():
        if ec2_util.check_instance_status() == "running":
            if mc_server_status["online"]:
                return { 'STATUS': "MC_SERVER_UP", 'COMMAND': task_data["action"], "INFO": "Minecraft Server Status - ONLINE"}

            task_id = task_data["task_id"]
            task_manager = TaskManager(dynambodb_table_name)
            task_status = task_manager.check_task_status(task_id)

            # Prepare Function Output
            status = task_status
            action = task_data["action"]
            info = f"Minecraft Server being started"

            return status, action, task_id, info
        else:
            return { 'STATUS': "MC_SERVER_DOWN", 'COMMAND': task_data["action"], "INFO": "Minecraft Server Status - OFFLINE"}
    else:
        error_message = "EC2 Instance does not exist!"
        raise Exception(error_message)