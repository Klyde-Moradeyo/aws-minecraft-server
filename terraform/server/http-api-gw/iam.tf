############################
#        IAM Role          #
############################
module "iam_role" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-role/aws"
  version = "0.0.1"

  name        = var.name
  path        = "/http-api-gw/"
  description = "IAM Role for ${local.api_name} HTTP API Gateway"

  trust_policy_hcl = {
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "apigateway.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  }

  policy_arns = {
    
  }

  tags = var.tags
}

############################
#       IAM Policy         #
############################
module "iam_policy" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = var.name
  description = "IAM Policy for ${local.api_name} HTTP API Gateway"

  policy_hcl = {
      Version = "2012-10-17"
      Statement = [
        {
          Action   = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:PutLogEvents",
            "logs:GetLogEvents",
            "logs:FilterLogEvents"
          ],
          Effect   = "Allow",
          Resource = module.cloudwatch_log.arn
        },
      ]
    }

  tags = module.tags.tags
}