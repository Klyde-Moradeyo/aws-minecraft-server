### Work In Progress -- Policies are not optimized

locals {
  iam_policy_create = "${var.name}-create"
  iam_policy_read = "${var.name}-read"
  iam_policy_update = "${var.name}-update"
  iam_policy_delete = "${var.name}-delete"
  iam_policy_tf_s3_state_access = "${var.name}-tf-s3-state-access"
}

module "iam_policy_create" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.iam_policy_create
  description = "IAM policy for creating resources."
  path        = "/ci-cd/${data.terraform_remote_state.my_state.outputs.tags["Project"]}/"

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
          "dynamodb:CreateTable",
          "dynamodb:DeleteTable",
          "events:PutRule",
          "events:PutTargets",
          "events:DeleteRule",
          "events:RemoveTargets",
          "ssm:PutParameter"
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
  path        = "/ci-cd/${data.terraform_remote_state.my_state.outputs.tags["Project"]}/"

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ResourceManagementRead"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ecs:Describe*",
          "iam:Get*",
          "iam:List*",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "s3:Get*",
          "s3:List*",
          "apigateway:GET",
          "ecs:Describe*",
          "ecr:Describe*",
          "logs:Describe*",
          "logs:List*",
          "lambda:Get*",
          "lambda:List*",
          "ssm:Describe*",
          "ssm:List*",
          "dynamodb:Describe*",
          "dynamodb:List*",
          "events:Describe*",
          "ecr:Get*",
          "ecr:List*"
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
  path        = "/ci-cd/${data.terraform_remote_state.my_state.outputs.tags["Project"]}/"

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ResourceManagementUpdate"
        Effect = "Allow"
        Action = [
          "ec2:Modify*",
          "ec2:AssociateAddress",
          "ec2:AuthorizeSecurityGroupIngress",
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
          "dynamodb:UpdateTable",
          "dynamodb:Tag*",
          "events:PutRule",
          "events:PutTargets"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Project"   = data.terraform_remote_state.my_state.outputs.tags["Project"]
            "aws:ResourceTag/Namespace" = data.terraform_remote_state.my_state.outputs.tags["Namespace"]
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
  path        = "/ci-cd/${data.terraform_remote_state.my_state.outputs.tags["Project"]}/"

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ResourceManagementDelete"
        Effect = "Allow"
        Action = [
          "ec2:Delete*",
          "ec2:DisassociateAddress",
          "iam:Delete*",
          "s3:Delete*",
          "apigateway:DELETE",
          "ecs:DeregisterTaskDefinition",
          "ecs:DeleteCluster",
          "ecr:DeleteRepository",
          "ecr:DeleteLifecyclePolicy",
          "logs:DeleteLogGroup",
          "lambda:DeleteFunction",
          "lambda:RemovePermission",
          "dynamodb:DeleteTable",
          "events:DeleteRule",
          "events:RemoveTargets",
          "ssm:DeleteParameter"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Project"   = data.terraform_remote_state.my_state.outputs.tags["Project"]
            "aws:ResourceTag/Namespace" = data.terraform_remote_state.my_state.outputs.tags["Namespace"]
          }
        }
      }
    ]
  }

  tags = data.terraform_remote_state.my_state.outputs.tags
}

module "iam_policy_tf_s3_state_access" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.iam_policy_tf_s3_state_access
  description = "Policy for Terraform to manage its remote state in S3"
  path        = "/ci-cd/${data.terraform_remote_state.my_state.outputs.tags["Project"]}/"

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.remote_state_bucket}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:PutObjectAcl"
        ]
        Resource = [
          "arn:aws:s3:::${var.remote_state_bucket}/*"
        ]
      }
    ]
  }

  tags = data.terraform_remote_state.my_state.outputs.tags
}