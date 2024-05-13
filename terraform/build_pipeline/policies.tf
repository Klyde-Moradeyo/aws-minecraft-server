locals {
  iam_policy_create = "${var.name}-create"
  iam_policy_read = "${var.name}-read"
  iam_policy_update = "${var.name}-update"
  iam_policy_delete = "${var.name}-delete"
}

module "iam_policy_create" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.iam_policy_create
  description = "IAM policy for creating resources."
  path        = "/CI-CD/"

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ResourceManagementCreate"
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

module "iam_policy_read" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.iam_policy_read
  description = "IAM policy for reading resources."
  path        = "/CI-CD/"

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ResourceManagementRead"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "iam:Get*",
          "iam:List*",
          "s3:Get*",
          "s3:List*",
          "apigateway:GET",
          "ecs:Describe*",
          "ecr:Describe*",
          "logs:Describe*",
          "lambda:Get*",
          "lambda:List*",
          "ssm:Describe*",
          "route53:Get*",
          "route53:List*",
          "dynamodb:Describe*",
          "events:Describe*"
        ]
        Resource = "*"
      }
    ]
  }

  tags = data.terraform_remote_state.my_state.outputs.tags
}

module "iam_policy_update" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.iam_policy_update
  description = "IAM policy for updating resources with specific tags."
  path        = "/CI-CD/"

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ResourceManagementUpdate"
        Effect = "Allow"
        Action = [
          "ec2:Modify*",
          "iam:Put*",
          "iam:PassRole",
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
          "logs:PutRetentionPolicy",
          "lambda:UpdateFunctionConfiguration",
          "lambda:UpdateFunctionCode",
          "route53:ChangeResourceRecordSets",
          "dynamodb:UpdateTable",
          "events:PutRule",
          "events:PutTargets"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/project"   = data.terraform_remote_state.my_state.outputs.tags["Project"]
            "aws:ResourceTag/namespace" = data.terraform_remote_state.my_state.outputs.tags["Namespace"]
          }
        }
      }
    ]
  }

  tags = data.terraform_remote_state.my_state.outputs.tags
}

module "iam_policy_delete" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.iam_policy_delete
  description = "IAM policy for deleting resources based on specific tags."
  path        = "/CI-CD/"

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ResourceManagementDelete"
        Effect = "Allow"
        Action = [
          "ec2:Delete*",
          "iam:Delete*",
          "s3:DeleteObject",
          "apigateway:DELETE",
          "ecs:DeregisterTaskDefinition",
          "ecs:DeleteCluster",
          "ecr:DeleteRepository",
          "ecr:DeleteLifecyclePolicy",
          "logs:DeleteLogGroup",
          "lambda:DeleteFunction",
          "route53:DeleteHostedZone",
          "dynamodb:DeleteTable",
          "events:DeleteRule",
          "events:RemoveTargets"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/project"   = data.terraform_remote_state.my_state.outputs.tags["Project"]
            "aws:ResourceTag/namespace" = data.terraform_remote_state.my_state.outputs.tags["Namespace"]
          }
        }
      }
    ]
  }

  tags = data.terraform_remote_state.my_state.outputs.tags
}



