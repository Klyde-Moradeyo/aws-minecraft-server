############################
#        IAM Role          #
############################
module "iam_role" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-role/aws"
  version = "0.0.1"

  name = var.name

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

  policy_arns = {}

  tags = var.tags
}

############################
#       IAM Policy         #
############################
module "iam_policy" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = var.name
  path        = "/Lambda"
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
        # Resource = "*"
      }
    ]
  }

  tags = var.tags
}