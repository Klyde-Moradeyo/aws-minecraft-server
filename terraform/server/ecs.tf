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
  mc_archive_ecr_repo_name = module.mc_world_archive_ecr_registry.ecr_repository_name

  # S3 
  minecraft_world_s3_bucket  = module.s3_mc_world.s3_bucket_arn
  minecraft_assets_s3_bucket = module.s3_mc_server_assets.s3_bucket_arn

  # Module tags
  tags = module.tags.tags
}