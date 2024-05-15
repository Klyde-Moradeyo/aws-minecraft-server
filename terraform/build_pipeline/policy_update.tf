module "iam_policy_update" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.iam_policy_update
  description = "IAM policy for reading resources."
  path        = local.iam_path

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CICDUserUpdatePermissions"
        Effect = "Allow"
        Action = [
          "ec2:Modify*",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:StopInstances",
          "ec2:StartInstances",
          "ec2:ImportKeyPair",
          "iam:Put*",
          "iam:Attach*",
          "iam:Detach*",
          "iam:PassRole",
          "s3:Put*",
          "apigateway:PATCH",
          "ecs:Update*",
          "ecr:Put*",
          "logs:PutRetentionPolicy",
          "lambda:Update*",
          "lambda:PutFunctionConcurrency",
          "dynamodb:Update*",
          "events:Update*"
        ]
        Resource = ["*"]
      },
      {
        Sid    = "CICDUserReadSSMParamPermissions"
        Effect = "Allow"
        Action = [
          "ssm:PutParameter",
          "ssm:AddTagsToResource"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/${data.terraform_remote_state.my_state.outputs.name}-*/ec2_private_key"
      }
    ]
  }

  tags = local.tags
}


