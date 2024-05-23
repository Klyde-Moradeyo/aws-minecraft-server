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

module "ecs_cluster" {
  source = "../ecs-cluster"

  name = var.name
  capacity_providers = ["FARGATE"]
  container_insights = true
  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
      weight            = 1
      base              = 1
    }
  ]

  tags = module.tags.tags
}

module "ecs_task_definition" {
  source                = "../ecs-fargate-task-definition"
  
  task_name             = "my-task"
  docker_image          = "my-docker-image:latest"
  cpu                   = "256"
  memory                = "512"
  cluster_arn           = "arn:aws:ecs:us-east-1:123456789012:cluster/my-cluster"
  enable_autoscaling    = true
  max_capacity          = 10
  min_capacity          = 1
  autoscaling_policies  = [
    {
      name               = "cpu-scaling"
      policy_type        = "TargetTrackingScaling"
      target_value       = 75
      metric_type        = "ECSServiceAverageCPUUtilization"
      scale_in_cooldown  = 300
      scale_out_cooldown = 300
      disable_scale_in   = false
    },
    {
      name               = "memory-scaling"
      policy_type        = "TargetTrackingScaling"
      target_value       = 75
      metric_type        = "ECSServiceAverageMemoryUtilization"
      scale_in_cooldown  = 300
      scale_out_cooldown = 300
      disable_scale_in   = true
    }
  ]

  task_role_policy_arns = {
    "${local.ecs_to_s3_access_policy}" = module.ecs_to_s3_access_policy.policy_arn
  }
}

################################
#       ECS IAM Policy         #
################################
locals {
  ecs_to_s3_access_policy = "${var.name}-ecs-to-s3-access"
}

module "ecs_to_s3_access_policy" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.ecs_to_s3_access_policy
  description = "IAM Policy for ${var.name} Request Lambda to access various AWS services"

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:ListBucket"]
        Resource = [
          module.s3_mc_world.arn,
          module.s3_mc_server_assets.arn
        ]
      },
      {
        Effect = "Allow"
        Action = ["s3:GetObject"]
        Resource = [
          "${module.s3_mc_world.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:CreateMultipartUpload"
        ]
        Resource = [
          "${module.s3_mc_server_assets.arn}/*/world_bck_up/*"
        ]
      }
    ]
  }

  tags = module.tags.tags
}