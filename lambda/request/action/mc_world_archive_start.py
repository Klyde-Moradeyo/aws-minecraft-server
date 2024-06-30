from utils.fargate import FargateUtil

def handle(task_data, envs, mc_server, ec2_util, logger):
    logger.info("Handling 'Start Minecraft World Archive' Action...")
    action = task_data["action"]
    task_id = None # Not used for this action

    # Create Network Config for Fargate
    network_config = FargateUtil.create_network_config([envs["ECS_SUBNET_ID"]])
    
    # Create environment_vars
    environment_vars = None # [ {'name': 'S3_MC_WORLD_URI', 'value': envs["S3_MC_WORLD_URI"]}, ]
    
    # Initialize Fargate Container
    fargate_utils = FargateUtil(envs["ECS_CLUSTER_NAME"], envs["ECS_MC_ARCHIVE_TASK_DEFINITION_NAME"], envs["ECS_MC_ARCHIVE_CONTAINER_NAME"], environment_vars, network_config, envs)
    
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