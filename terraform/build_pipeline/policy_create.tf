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
          "ec2:ImportKeyPair",
          "ec2:AllocateAddress",
          "ec2:AssociateAddress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RunInstances",
          "ec2:AttachInternetGateway",
          "ec2:AssociateRouteTable",
          "iam:Create*",
          "iam:Tag*",
          "iam:AddRoleToInstanceProfile",
          "s3:CreateBucket",
          "s3:PutObject",
          "s3:PutBucketTagging",
          "s3:PutBucketLogging",
          "s3:PutBucketPolicy",
          "s3:PutBucketAcl",
          "s3:PutBucketPublicAccessBlock",
          "s3:PutBucketOwnershipControls",
          "s3:PutLifecycleConfiguration",
          "apigateway:POST",
          "apigateway:Tag*",
          "ecs:CreateCluster",
          "ecs:RegisterTaskDefinition",
          "ecr:CreateRepository",
          "ecr:PutLifecyclePolicy",
          "ecr:Tag*",
          "ecr:ListTagsForResource",
          "logs:CreateLogGroup",
          "lambda:CreateFunction",
          "lambda:AddPermission",
          "lambda:TagResource",
          "lambda:PublishVersion",
          "dynamodb:CreateTable",
          "dynamodb:Tag*",
          "dynamodb:ListTagsOfResource",
          "events:PutRule",
          "events:PutTargets",
          "events:Tag*",
          "logs:Tag*",
          "logs:ListTagsLogGroup",
          "logs:CreateLogDelivery"
        ]
        Resource = ["*"]
      }
    ]
  }

  tags = data.terraform_remote_state.my_state.outputs.tags
}