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
          "ec2:TerminateInstances",
          "ec2:DisassociateAddress",
          "ec2:ReleaseAddress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:DisassociateRouteTable",
          "iam:Delete*",
          "iam:RemoveRoleFromInstanceProfile",
          "s3:Delete*",
          "apigateway:DELETE",
          "ecs:Delete*",
          "ecr:Delete*",
          "logs:DeleteLogGroup",
          "lambda:DeleteFunction",
          "lambda:RemovePermission",
          "dynamodb:DeleteTable",
          "events:DeleteRule",
          "events:RemoveTargets",
          "ecs:DeregisterTaskDefinition",
        ]
        Resource = ["*"]
      },
      {
        Sid    = "CICDUserReadSSMParamPermissions"
        Effect = "Allow"
        Action = [
          "ssm:DeleteParameter"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/${data.terraform_remote_state.my_state.outputs.name}-*/ec2_private_key"
      }
    ]
  }

  tags = data.terraform_remote_state.my_state.outputs.tags
}
