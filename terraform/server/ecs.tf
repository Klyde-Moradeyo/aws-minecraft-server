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
  minecraft_world_s3_bucket  = module.s3_mc_world.bucket_arn
  minecraft_assets_s3_bucket = module.s3_mc_server_assets.bucket_arn

  # Module tags
  tags = module.tags.tags
}