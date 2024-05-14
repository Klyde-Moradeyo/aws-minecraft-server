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
        Sid    = "CICDUserReadPermissions"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:GetConsoleOutput",
          "ec2:DetachInternetGateway",
          "iam:Get*",
          "iam:List*",
          "s3:ListBucket",
          "s3:Get*",
          "apigateway:GET",
          "ecs:Describe*",
          "ecr:Describe*",
          "ecr:Get*",
          "logs:Describe*",
          "logs:ListLogDeliveries",
          "lambda:Get*",
          "lambda:ListVersionsByFunction",
          "ssm:DescribeParameters",
          "dynamodb:Describe*",
          "events:Describe*",
          "events:ListTagsForResource",
          "events:ListTargetsByRule"
        ]
        Resource = ["*"]
      },
      {
        Sid    = "CICDUserReadSSMParamPermissions"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:ListTagsForResource",
        ]
        Resource = "arn:aws:ssm:*:*:parameter/${data.terraform_remote_state.my_state.outputs.name}-*/ec2_private_key"
      }
    ]
  }

  tags = data.terraform_remote_state.my_state.outputs.tags
}


