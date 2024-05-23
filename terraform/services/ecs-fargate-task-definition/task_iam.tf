############################
#        IAM Role          #
############################
module "ecs_execution_role" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-role/aws"
  version = "0.0.1"

  name        = "${var.name}-task"
  path        = "/ecs/"
  description = "IAM Execution Role for ECS ${var.name} Task Defintion in ${var.ecs_cluster_name} cluster"

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
    "${local.ecs_execution_role_policy}" = module.ecs_execution_role_policy.policy_arn
  }

  tags = var.tags
}

############################
#       IAM Policy         #
############################
locals {
  ecs_execution_role_policy = "${var.name}-lambda-cloudwatch-logs-access"
}

module "ecs_execution_role_policy" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.iam_policy_name
  path        = "/Lambda/"
  description = "An IAM policy for ${var.name} lambda access to cloudwatch logs"

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          module.cloudwatch_log.arn,
          "${module.cloudwatch_log.arn}:*"
        ]
      }
    ]
  }

  tags = var.tags
}
