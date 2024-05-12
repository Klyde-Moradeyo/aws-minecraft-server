#### EC2 ####
module "iam_policy_ec2" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = "ec2-user-policy"
  description = "EC2 management policy for specific resources"
  path        = "/ec2/"

  policy_hcl = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "EC2ManagementPermissions",
        "Effect": "Allow",
        "Action": [
          "ec2:Describe*",
          "ec2:Create*",
          "ec2:Delete*",
          "ec2:Modify*",
          "ec2:AllocateAddress",
          "ec2:AssociateAddress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RunInstances",
          "ec2:StopInstances",
          "ec2:MonitorInstances",
          "ec2:TerminateInstances",
          "ec2:DisassociateAddress",
          "ec2:ReleaseAddress",
          "ec2:AttachInternetGateway",
          "ec2:AssociateRouteTable",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:StartInstances"
        ],
        "Resource": [
          "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:instance/*",
          "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:volume/*",
          "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:subnet/*",
          "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:security-group/*"
        ]
      }
    ]
  }
  EOF

  tags = var.tags
}

#### S3 ####
module "iam_policy_s3" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = "s3-user-policy"
  description = "S3 access policy for specific buckets"
  path        = "/s3/"

  policy_hcl = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "S3BucketPermissions",
        "Effect": "Allow",
        "Action": [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:GetBucketPolicy",
          "s3:PutBucketTagging",
          "s3:PutBucketLogging",
          "s3:GetBucketLogging",
          "s3:PutBucketPolicy", 
          "s3:PutBucketAcl",
          "s3:GetBucketAcl",
          "s3:PutBucketPublicAccessBlock",
          "s3:PutBucketOwnershipControls",
          "s3:GetBucketCORS",
          "s3:GetBucketWebsite",
          "s3:GetBucketVersioning",
          "s3:PutBucketVersioning",
          "s3:GetAccelerateConfiguration",
          "s3:PutAccelerateConfiguration",
          "s3:GetBucketRequestPayment",
          "s3:PutBucketRequestPayment",
          "s3:GetLifecycleConfiguration",
          "s3:PutLifecycleConfiguration",
          "s3:GetReplicationConfiguration",
          "s3:PutReplicationConfiguration",
          "s3:GetBucketEncryption",
          "s3:PutBucketEncryption",
          "s3:GetEncryptionConfiguration",
          "s3:GetObjectLockConfiguration",
          "s3:GetBucketObjectLockConfiguration",
          "s3:ListBucketTags",
          "s3:GetBucketTagging"
        ],
        "Resource": [
          "arn:aws:s3:::${data.terraform_remote_state.my_state.outputs.my_bucket_name}",
          "arn:aws:s3:::${data.terraform_remote_state.my_state.outputs.my_bucket_name}/*"
        ]
      }
    ]
  }
  EOF

  tags = var.tags
}

#### Lambda ####
module "iam_policy_lambda" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = "lambda-user-policy"
  description = "Lambda function management policy"
  path        = "/lambda/"

  policy_hcl = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "LambdaFunctionPermissions",
        "Effect": "Allow",
        "Action": [
          "lambda:CreateFunction",
          "lambda:TagResource",
          "lambda:ListVersionsByFunction",
          "lambda:GetFunction",
          "lambda:GetFunctionCodeSigningConfig",
          "lambda:DeleteFunction",
          "lambda:AddPermission",
          "lambda:GetPolicy",
          "lambda:RemovePermission",
          "lambda:UpdateFunctionConfiguration",
          "lambda:UpdateFunctionCode",
          "lambda:GetLayerVersion"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF

  tags = var.tags
}

module "iam_policy_apigateway" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = "apigateway-user-policy"
  description = "API Gateway management policy"
  path        = "/apigateway/"

  policy_hcl = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "APIGatewayPermissions",
        "Effect": "Allow",
        "Action": [
          "apigateway:POST",
          "apigateway:GET",
          "apigateway:DELETE",
          "apigateway:TagResource",
          "apigateway:PATCH"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF

  tags = var.tags
}

module "iam_policy_ecs_ecr" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = "ecs-ecr-user-policy"
  description = "ECS and ECR management policy"
  path        = "/ecs-ecr/"

  policy_hcl = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "ECSandECRPermissions",
        "Effect": "Allow",
        "Action": [
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeTaskDefinition",
          "ecs:CreateCluster",
          "ecs:DeregisterTaskDefinition",
          "ecs:DescribeClusters",
          "ecs:DeleteCluster",
          "ecs:TagResource",
          "ecs:ListTagsForResource",
          "ecs:UntagResource",
          "ecr:CreateRepository",
          "ecr:TagResource",
          "ecr:DescribeRepositories",
          "ecr:ListTagsForResource",
          "ecr:DeleteRepository",
          "ecr:GetAuthorizationToken",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutLifecyclePolicy",
          "ecr:GetLifecyclePolicy",
          "ecr:DeleteLifecyclePolicy"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF

  tags = var.tags
}

module "iam_policy_dynamodb" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = "dynamodb-user-policy"
  description = "DynamoDB management policy"
  path        = "/dynamodb/"

  policy_hcl = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "DynamoDBPermissions",
        "Effect": "Allow",
        "Action": [
          "dynamodb:CreateTable",
          "dynamodb:TagResource",
          "dynamodb:UntagResource",
          "dynamodb:UpdateTable",
          "dynamodb:DeleteTable",
          "dynamodb:DescribeTable",
          "dynamodb:DescribeContinuousBackups",
          "dynamodb:DescribeTimeToLive",
          "dynamodb:UpdateTimeToLive",
          "dynamodb:ListTagsOfResource"
        ],
        "Resource": [
          "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${data.terraform_remote_state.my_state.outputs.my_dynamodb_table_name}"
        ]
      }
    ]
  }
  EOF

  tags = var.tags
}