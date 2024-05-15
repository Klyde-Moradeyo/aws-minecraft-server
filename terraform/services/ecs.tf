########################
#         ECS          #
########################
module "ecs_cluster" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/ecs?ref=tf-modules"

  aws_region = var.aws_region

  # Task Resources
  task_cpu_limit    = 256
  task_memory_limit = 1024

  # SSM
  ssm_git_private_key_name = "dark-mango-bot-private-key"

  # Task Defintion 
  mc_archive_ecr_repo_name = module.ecr_mc_world_archive.repository_name

  # S3 
  minecraft_world_s3_bucket  = module.s3_mc_world.arn
  minecraft_assets_s3_bucket = module.s3_mc_server_assets.arn

  # Module tags
  tags = module.tags.tags
}

# module "ecs_cluster" {
#   source = "./ecs-cluster"

#   name = var.name
#   capacity_providers = ["FARGATE", "FARGATE_SPOT"]
#   container_insights = true
#   default_capacity_provider_strategy = [
#     {
#       capacity_provider = "FARGATE"
#       weight            = 1
#       base              = 1
#     },
#     {
#       capacity_provider = "FARGATE_SPOT"
#       weight            = 2
#       base              = 0
#     }
#   ]

#   tags = module.tags.tags
# }