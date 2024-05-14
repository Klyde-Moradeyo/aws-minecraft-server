module "iam_policy_read" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.iam_policy_read
  description = "IAM policy for reading resources."
  path        = local.iam_path

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CICDUserReadPermissions"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "iam:Get*",
          "iam:List*",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:GetBucketPolicy",
          "s3:GetBucketAcl",
          "s3:GetBucketLogging",
          "s3:GetBucketPublicAccessBlock",
          "s3:GetBucketOwnershipControls",
          "s3:GetBucketCORS",
          "s3:GetBucketWebsite",
          "s3:GetBucketVersioning",
          "s3:GetAccelerateConfiguration",
          "s3:GetBucketRequestPayment",
          "s3:GetLifecycleConfiguration",
          "s3:GetReplicationConfiguration",
          "s3:GetBucketEncryption",
          "s3:GetEncryptionConfiguration",
          "s3:GetObjectLockConfiguration",
          "s3:GetBucketTagging",
          "s3:GetPublicAccessBlock",
          "apigateway:GET",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeClusters",
          "ecr:DescribeRepositories",
          "ecr:GetAuthorizationToken",
          "ecr:GetLifecyclePolicy",
          "logs:DescribeLogGroups",
          "logs:ListTagsLogGroup",
          "lambda:GetFunction",
          "lambda:GetFunctionCodeSigningConfig",
          "lambda:ListVersionsByFunction",
          "lambda:GetPolicy",
          "lambda:GetLayerVersion",
          "ssm:DescribeParameters",
          "route53:GetHostedZone",
          "route53:ListTagsForResource",
          "route53:GetChange",
          "route53:ListResourceRecordSets",
          "dynamodb:DescribeTable",
          "dynamodb:DescribeContinuousBackups",
          "dynamodb:DescribeTimeToLive",
          "dynamodb:ListTagsOfResource",
          "events:DescribeRule",
          "events:ListTagsForResource",
          "events:ListTargetsByRule"
        ]
        Resource = "*"
      },
      {
        Sid    = "CICDUserReadSSMParamPermissions"
        Effect   = "Allow"
        Action   = "ssm:GetParameter"
        Resource = "arn:aws:ssm:*:*:parameter/${data.terraform_remote_state.my_state.outputs.name}-*"
      }
    ]
  }

  tags = data.terraform_remote_state.my_state.outputs.tags
}


