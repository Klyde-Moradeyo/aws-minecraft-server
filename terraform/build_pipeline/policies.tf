module "iam_policy" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = var.name
  description = "IAM policy granting access based on specific tags for managing AWS resources."
  path        = "/CI-CD/"

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ResourceManagementReadWriteBasedOnTag"
        Effect = "Allow"
        Action = [
          "ec2:Modify",
          "ec2:Describe",
          "iam:Get",
          "iam:List",
          "iam:Put",
          "iam:PassRole",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:AttachUserPolicy",
          "s3:ListBucket",
          "s3:Get",
          "s3:Put",
          "apigateway:GET",
          "apigateway:PATCH",
          "apigateway:TagResource",
          "ecs:Describe",
          "ecs:TagResource",
          "ecs:ListTagsForResource",
          "ecs:UntagResource",
          "ecr:TagResource",
          "ecr:Describe",
          "ecr:ListTagsForResource",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutLifecyclePolicy",
          "ecr:GetLifecyclePolicy",
          "logs:PutRetentionPolicy",
          "logs:Describe",
          "logs:ListTagsLogGroup",
          "lambda:TagResource",
          "lambda:ListVersionsByFunction",
          "lambda:Get",
          "lambda:UpdateFunctionConfiguration",
          "lambda:UpdateFunctionCode",
          "lambda:RemovePermission",
          "lambda:AddPermission",
          "ssm:DescribeParameters",
          "route53:GetHostedZone",
          "route53:ListTagsForResource",
          "route53:GetChange",
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets",
          "dynamodb:TagResource",
          "dynamodb:UntagResource",
          "dynamodb:UpdateTable",
          "dynamodb:Describe",
          "events:DescribeRule",
          "events:ListTagsForResource",
          "events:ListTargetsByRule",
          "events:TagResource",
          "events:UntagResource"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/project"   = data.terraform_remote_state.my_state.outputs.tags["Project"]
            "aws:ResourceTag/namespace" = data.terraform_remote_state.my_state.outputs.tags["Namespace"]
          }
        }
      },
      {
        Sid    = "ResourceManagementCreateDelete"
        Effect = "Allow"
        Action = [
          "ec2:Create*",
          "ec2:Delete*",
          "iam:Create*",
          "iam:Delete*",
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:DeleteObject",
          "apigateway:POST",
          "apigateway:DELETE",
          "ecs:RegisterTaskDefinition",
          "ecs:CreateCluster",
          "ecs:DeregisterTaskDefinition",
          "ecs:DeleteCluster",
          "ecr:CreateRepository",
          "ecr:DeleteRepository",
          "ecr:DeleteLifecyclePolicy",
          "logs:CreateLogGroup",
          "logs:DeleteLogGroup",
          "lambda:CreateFunction",
          "lambda:DeleteFunction",
          "ssm:AddTagsToResource",
          "route53:CreateHostedZone",
          "route53:DeleteHostedZone",
          "dynamodb:CreateTable",
          "dynamodb:DeleteTable",
          "events:PutRule",
          "events:PutTargets",
          "events:DeleteRule",
          "events:RemoveTargets"
        ]
        Resource = "*"
      }
    ]
  }


  tags = data.terraform_remote_state.my_state.outputs.tags
}
