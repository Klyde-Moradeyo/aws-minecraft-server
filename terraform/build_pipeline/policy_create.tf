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
        Sid    = "CICDUserCreatePermissions"
        Effect = "Allow"
        Action = [
          "ec2:Create*",
          "ec2:RunInstances",
          "iam:Create*",
          "s3:CreateBucket",
          "s3:PutBucket*",
          "apigateway:POST",
          "ecs:RegisterTaskDefinition",
          "ecs:CreateCluster",
          "ecr:CreateRepository",
          "logs:CreateLogGroup",
          "lambda:CreateFunction",
          "ssm:AddTagsToResource",
          "route53:CreateHostedZone",
          "dynamodb:CreateTable",
          "events:PutRule",
          "events:PutTargets"
        ]
        Resource = [
          "arn:aws:ec2:*:*:instance/${data.terraform_remote_state.my_state.outputs.name}-*",
          "arn:aws:iam::*:role/${data.terraform_remote_state.my_state.outputs.name}-*",
          "arn:aws:s3:::${data.terraform_remote_state.my_state.outputs.name}-*",
          "arn:aws:apigateway:*::/restapis/${data.terraform_remote_state.my_state.outputs.name}-*",
          "arn:aws:ecs:*:*:cluster/${data.terraform_remote_state.my_state.outputs.name}-*",
          "arn:aws:ecr:*:*:repository/${data.terraform_remote_state.my_state.outputs.name}-*",
          "arn:aws:logs:*:*:log-group:${data.terraform_remote_state.my_state.outputs.name}-*",
          "arn:aws:lambda:*:*:function:${data.terraform_remote_state.my_state.outputs.name}-*",
          "arn:aws:ssm:*:*:parameter/${data.terraform_remote_state.my_state.outputs.name}-*",
          "arn:aws:route53:::hostedzone/${data.terraform_remote_state.my_state.outputs.name}-*",
          "arn:aws:dynamodb:*:*:table/${data.terraform_remote_state.my_state.outputs.name}-*",
          "arn:aws:events:*:*:rule/${data.terraform_remote_state.my_state.outputs.name}-*"
        ]
      }
    ]
  }

  tags = data.terraform_remote_state.my_state.outputs.tags
}