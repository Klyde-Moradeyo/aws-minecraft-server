module "iam_policy_update" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.iam_policy_update
  description = "IAM policy for updating resources with specific tags."
  path        = local.iam_path

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ResourceManagementUpdate"
        Effect = "Allow"
        Action = [
          "ec2:Modify*",
          "ec2:AssociateAddress",
          "ec2:AllocateAddress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RunInstances",
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:TerminateInstances",
          "ec2:RevokeSecurityGroupEgress",
          "iam:Put*",
          "iam:PassRole",
          "iam:Tag*",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:AttachUserPolicy",
          "s3:Put*",
          "apigateway:PATCH",
          "apigateway:TagResource",
          "ecs:TagResource",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutLifecyclePolicy",
          "ecr:Tag*",
          "logs:PutRetentionPolicy",
          "logs:Tag*",
          "lambda:UpdateFunctionConfiguration",
          "lambda:UpdateFunctionCode",
          "lambda:Tag*",
          "lambda:Put*",
          "lambda:AddPermission",
          "dynamodb:UpdateTable",
          "dynamodb:UpdateTimeToLive",
          "dynamodb:Tag*",
          "events:PutRule",
          "events:PutTargets",
          "events:Tag*"
        ]
        Resource = "*"
        # Condition = {
        #   StringEquals = {
        #     "aws:ResourceTag/Project"   = data.terraform_remote_state.my_state.outputs.tags["Project"]
        #     "aws:ResourceTag/Namespace" = data.terraform_remote_state.my_state.outputs.tags["Namespace"]
        #   }
        # }
      }
    ]
  }

  tags = data.terraform_remote_state.my_state.outputs.tags
}