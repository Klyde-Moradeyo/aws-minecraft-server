############################
#        IAM Role          #
############################
# Task Execution Role
# Allows ECS agent to pull images, store logs, and manage network on behalf of the task.
module "execution_role" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-role/aws"
  version = "0.0.1"

  name        = "${var.name}-execution"
  path        = "/ecs/"
  description = "IAM Execution Role for ECS ${var.name} Task Defintion"

  trust_policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  }

  policy_arns = {
    "${local.execution_role_cloudwatch_log_policy}" = module.execution_role_cloudwatch_log_policy.policy_arn
    "${local.execution_role_ecr_policy}"            = module.execution_role_ecr_policy[0].policy_arn
  }

  tags = var.tags
}

############################
#       IAM Policy         #
############################
locals {
  execution_role_ecr_policy            = "${var.name}-ecr-access"
  execution_role_cloudwatch_log_policy = "${var.name}-cloudwatch-log-access"
}

module "execution_role_ecr_policy" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  count = length(var.ecr_repo_arns) > 0 ? 1 : 0

  name        = local.execution_role_ecr_policy
  path        = "/ecs/"
  description = "An IAM policy for ${var.name} ECS Task Definition access to ECR repos"

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
        ],
        Resource = ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
        ],
        Resource = ["*"]
      }
    ]
  }

  tags = var.tags
}

locals {
  cloudwatch_log_arns      = values(module.cloudwatch_log)[*].arn
  cloudwatch_log_arns_wild = [for arn in local.cloudwatch_log_arns : "${arn}:*"]
  all_cloudwatch_log_arns  = concat(local.cloudwatch_log_arns, local.cloudwatch_log_arns_wild)
}

module "execution_role_cloudwatch_log_policy" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.execution_role_cloudwatch_log_policy
  path        = "/ecs/"
  description = "An IAM policy for ${var.name} ECS Task Definitions Containers' access to Cloudwatch logs"

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = local.all_cloudwatch_log_arns
      }
    ]
  }

  tags = var.tags
}