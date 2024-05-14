module "iam_policy_create" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.iam_policy_create
  description = "IAM policy for creating resources."
  path        = local.iam_path

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ResourceManagementCreate"
        Effect = "Allow"
        Action = [
          "ec2:Create*",
          "iam:Create*",
          "s3:CreateBucket",
          "apigateway:POST",
          "ecs:RegisterTaskDefinition",
          "ecs:CreateCluster",
          "ecr:CreateRepository",
          "logs:CreateLogGroup",
          "lambda:CreateFunction",
          "ssm:AddTagsToResource",
          "dynamodb:CreateTable",
          "ssm:PutParameter"
        ]
      Resource = "*"
      }
    ]
  } 

  tags = data.terraform_remote_state.my_state.outputs.tags
}