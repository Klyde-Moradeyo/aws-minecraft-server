########################
#         ECS          #
########################
module "ecs_cluster" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/ecs-cluster/aws"
  version = "0.0.1"

  name               = "${var.name}-world-archive"
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

locals {
  mc_archive_world_container_name  = "${var.name}-world-archive-runner"
  mc_archive_world_container_image = "${module.ecr_mc_world_archive.repository_url}:latest"
}

module "ecs_task_definition" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/ecs-fargate-task-definition/aws"
  version = "0.0.1"

  name        = "${var.name}-world-archive"
  cpu         = 256
  memory      = 1024
  cluster_arn = module.ecs_cluster.arn

  containers = [
    {
      name      = local.mc_archive_world_container_name
      image     = local.mc_archive_world_container_image
      cpu       = "256"
      memory    = "1024"
      essential = true
      environment_variables = [
        {
          name  = "S3_MC_WORLD_NAME",
          value = module.s3_mc_world.name
        },
        {
          name  = "S3_MC_ASSETS_NAME",
          value = module.s3_mc_server_assets.name
        }
      ]
    }
  ]

  # network_config = {
  #   subnets          =  module.public_subnet.subnet_ids
  #   security_groups  = []
  #   assign_public_ip = false
  # }

  task_role_policy_arns = {
    "${local.ecs_to_s3_access_policy}" = module.ecs_to_s3_access_policy.policy_arn
  }

  ecr_repo_arns = [module.ecr_mc_world_archive.repository_arn]

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