########################
#         ECS          #
########################
module "ecs_cluster" {
  source = "./ecs-cluster"

  name               = var.name
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
  source = "./ecs-fargate-task-definition"

  name          = "my-task"
  cpu                = "256"
  memory             = "1024"
  cluster_arn        = module.ecs_cluster.arn
  max_capacity       = 1
  min_capacity       = 1

  containers = [
    {
      name                  = "${var.name}-world-archive-runner"
      image                 = "${module.ecr_mc_world_archive.repository_arn}:latest"
      cpu                   = "128"
      memory                = "256"
      essential             = true
      environment_variables = [
        { 
          name = "S3_MC_WORLD_NAME", 
          value = module.s3_mc_world.name
        },
        { 
          name = "S3_MC_ASSETS_NAME", 
          value = module.s3_mc_server_assets.name
        }
      ]
    }
  ]

  task_role_policy_arns = {
    "${local.ecs_to_s3_access_policy}" = module.ecs_to_s3_access_policy.policy_arn
  }

  ecr_repo_arns = [ module.ecr_mc_world_archive.repository_arn ]

  log_retention_in_days = 120

  tags = module.tags.tags
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