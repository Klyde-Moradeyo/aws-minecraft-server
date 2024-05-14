module "iam_policy_delete" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.iam_policy_delete
  description = "IAM policy for deleting resources based on specific tags."
  path        = local.iam_path

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CICDUserDeletePermissions"
        Effect = "Allow"
        Action = [
          "ec2:Delete*",
          "iam:Delete*",
          "s3:Delete*",
          "apigateway:DELETE",
          "ecs:DeleteCluster",
          "ecs:DeregisterTaskDefinition",
          "ecr:DeleteRepository",
          "logs:DeleteLogGroup",
          "lambda:DeleteFunction",
          "route53:DeleteHostedZone",
          "dynamodb:DeleteTable",
          "events:DeleteRule",
          "events:RemoveTargets"
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
