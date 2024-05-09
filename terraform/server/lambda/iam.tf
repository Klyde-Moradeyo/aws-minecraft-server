############################
#        IAM Role          #
############################
module "iam_role" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-role/aws"
  version = "0.0.1"

  name = var.name
  description = "IAM Role for ${var.name} Lambda"

  trust_policy_hcl = { 
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  }

  policy_arns = {
    "${local.iam_policy_name}" = module.iam_policy.policy_arn
  }

  tags = var.tags
}

locals {
  iam_policy_name = "${var.name}-lambda-cloudwatch-logs-access"
}

############################
#       IAM Policy         #
############################
module "iam_policy" {
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
        Resource = module.cloudwatch_log.arn
      }
    ]
  }

  tags = var.tags
}