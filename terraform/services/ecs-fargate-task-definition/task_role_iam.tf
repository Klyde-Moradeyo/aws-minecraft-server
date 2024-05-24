############################
#        IAM Role          #
############################
# Task Role
# Grants container applications access to AWS services as needed by the tasks.
module "task_role" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-role/aws"
  version = "0.0.1"

  name        = "${var.name}-task"
  path        = "/ecs/"
  description = "IAM Task Role for ECS ${var.name} Task Defintion"

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

  policy_arns = var.task_role_policy_arns

  tags = var.tags
}