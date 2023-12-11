from utils.fargate import FargateUtil

def handle(task_data, envs, mc_server, ec2_util, logger):
    logger.info("Handling 'Start Minecraft World Archive' Action...")
    action = task_data["action"]
    task_id = None # Not used for this action
    
    # Initialize Fargate Container
    fargate_utils = FargateUtil(envs["ECS_CLUSTER_NAME"], envs["ECS_MC_ARCHIVE_TASK_DEFINITION_NAME"], envs["ECS_MC_ARCHIVE_CONTAINER_NAME"], None, envs)
    
    # Check If Task is already running
    is_task_running = fargate_utils.is_task_with_tags_exists()

    # If it is running
    if is_task_running:
        status = "MC_WORLD_ARCHIVE_RUNNING"
        info = "Another Minecraft World Archiver Container is already running"
        return status, action, task_id, info
    else:
        status = "MC_WORLD_ARCHIVE_NOT_RUNNING"
        info = "Another Minecraft World Archiver Container is already running"
        return status, action, task_id, info  