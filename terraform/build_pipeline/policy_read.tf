module "iam_policy_read" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.iam_policy_read
  description = "IAM policy for reading resources."
  path        = local.iam_path

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ResourceManagementRead"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ecs:Describe*",
          "iam:Get*",
          "iam:List*",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "s3:Get*",
          "s3:List*",
          "apigateway:GET",
          "ecs:Describe*",
          "ecr:Describe*",
          "ecr:Get*",
          "ecr:List*",
          "logs:Describe*",
          "logs:List*",
          "lambda:Get*",
          "lambda:List*",
          "ssm:Describe*",
          "ssm:List*",
          "dynamodb:Describe*",
          "dynamodb:List*",
          "events:Describe*",
          "events:List*"
        ]
        Resource = "*"
      }
    ]
  }

  tags = data.terraform_remote_state.my_state.outputs.tags
}
