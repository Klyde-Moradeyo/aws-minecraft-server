from utils.fargate import FargateUtil

CONTAINER_NAME = "MC_WORLD_ARCHIVE"

def handle(task_data, envs, mc_server, ec2_util, logger):
    logger.info("Handling 'Start Minecraft World Archive' Action...")
    action = task_data["action"]
    task_id = None # Not used for this action
    
    # Initialize Fargate Container
    fargate_utils = FargateUtil(envs["CLUSTER"], envs["MC_ARCHIVE_TASK_DEFINITION_NAME"], CONTAINER_NAME, {}, envs)
    
    # Check If Task is already running
    is_task_running = fargate_utils.is_task_with_tags_exists()

    # If it is running
    if is_task_running:
        status = "MC_WORLD_ARCHIVE_ALREADY_RUNNING"
        info = "Another Minecraft World Archiver Container is already running"
        return status, action, task_id, info
    
    # Start Fargate Container
    task_arn = fargate_utils.create_fargate_container()

    status = "MC_WORLD_ARCHIVE_STARTED"
    info = f"Fargate Task Started: '{task_arn}'"
    return status, action, task_id, info