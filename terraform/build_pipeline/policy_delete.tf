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
          "events:RemoveTargets"
        ]
        Resource = ["*"]
      }
    ]
  }

  tags = data.terraform_remote_state.my_state.outputs.tags
}
