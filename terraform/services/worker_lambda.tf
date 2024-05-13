locals {
  git_lambda_layer_arn = "arn:aws:lambda:${var.aws_region}:553035198032:layer:git-lambda2:8"
}

module "worker_lambda" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/lambda/aws"
  version = "0.0.2"

  name                    = "${var.name}-worker"
  handler                 = "lambda_function.lambda_handler"
  runtime                 = "python3.10"
  description             = "Worker Lambda Function to handle requests received from ${var.name} Request Lambda"
  timeout                 = 900
  memory_size             = 128
  publish                 = true

  zip_file                = "worker_lambda_latest.zip"

  environment = {
      SSM_GIT_PRIVATE_KEY           = "/${var.ssm_git_private_key_name}"
      SSM_EC2_PRIVATE_KEY           = module.ssm_mc_server_private_key.info["ec2_private_key"].name
      GIT_BRANCH                    = var.git_branch
      S3_MC_WORLD_URI               = module.s3_mc_world.bucket_arn
      S3_MC_ASSETS_URI              = module.s3_mc_server_assets.bucket_uri
      API_GW_URL                    = "${module.api_gateway.api_endpoint}/${local.minecraft_api_stage_name}"
    }

  layers = [
    local.git_lambda_layer_arn
  ]

  permissions = [
    {
      statement_id = "allow-request-lambda-invoke"
      action     = "lambda:InvokeFunction"
      principal  = "lambda.amazonaws.com"
      source_arn = module.request_lambda.arn
    }
  ]

  reserved_concurrent_executions = 1

  log_retention_in_days = 30

  tags = module.tags.tags
}

################################
#    Worker Lambda Policy      #
################################
locals {
  worker_lambda_s3_iam_policy = "${var.name}-worker-lambda-s3"
}
module "worker_lambda_s3_iam_policy" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.worker_lambda_s3_iam_policy
  description = "IAM Policy for ${var.name} Worker Lambda to access various AWS services"

 policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "SSMAccess"
        Effect = "Allow"
        Action = ["ssm:GetParameter"]
        Resource = [
          "arn:aws:ssm:*:847399026905:parameter/${var.ssm_git_private_key_name}",
          module.ssm_mc_server_private_key.info["arn"]
        ]
      },
      {
        Sid = "FargateAccess"
        Effect = "Allow"
        Action = [
          "ecs:RunTask",
          "ecs:StopTask",
          "ecs:DescribeTasks",
          "ecs:ListTasks"
        ]
        Resource = ["*"] # needs to be updated
      },
      {
        Sid = "EC2Access"
        Effect = "Allow"
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances"
        ]
        Resource = [ 
          module.minecraft_server.ec2_instance_arn 
          ]
      },
      {
        Sid = "EC2DescribeInstances"
        Effect = "Allow"
        Action = ["ec2:DescribeInstances"]
        Resource = ["*"]
      },
      {
        Sid = "DynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          module.dynamodb.arn
        ]
      }
    ]
  }

  tags = module.tags.tags
}

resource "aws_iam_role_policy_attachment" "example_role_policy_attachment" {
  role       = module.worker_lambda.iam_role_name
  policy_arn = module.worker_lambda_s3_iam_policy.policy_arn
}