##########################
#        Lambda          #
##########################
module "request_lambda" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/lambda/aws"
  version = "0.0.3"

  name                    = "${var.name}-request"
  handler                 = "lambda_function.lambda_handler"
  runtime                 = "python3.10"
  description             = "Lambda Function to handle requests to the ${var.name} api"
  timeout                 = 900
  memory_size             = 128
  publish                 = true

  zip_file                = "request_lambda_latest.zip"

  environment = {
      MC_SERVER_IP                        = module.minecraft_server.public_ip
      MC_PORT                             = var.mc_port
      EC2_INSTANCE_ID                     = module.minecraft_server.id
      WORKER_LAMBDA_NAME                  = module.worker_lambda.name
      DYNAMO_DB_TABLE_NAME                = module.dynamodb.name
      ECS_CLUSTER_NAME                    = module.ecs_cluster.ecs_cluster_name
      ECS_MC_ARCHIVE_TASK_DEFINITION_NAME = module.ecs_cluster.mc_archive_task_definition_name
      ECS_MC_ARCHIVE_CONTAINER_NAME       = module.ecs_cluster.mc_archive_task_container_name
      S3_MC_WORLD_URI                     = module.s3_mc_world.bucket_uri
      S3_MC_ASSETS_URI                    = module.s3_mc_server_assets.bucket_uri
      ECS_SUBNET_ID                       = module.public_subnet.subnet_ids[0]
      ECS_SECURITY_GROUP_ID               = module.security_group.security_group_id
      TAGS_JSON                           = jsonencode(module.tags.tags)
    }

  permissions = [
    {
      statement_id = "allow-event-bridge-invoke"
      action     = "lambda:InvokeFunction"
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.monthly_schedule.arn
    }
  ]

  log_retention_in_days = 30

  tags = module.tags.tags
}


####################################
#   Request Lambda Event Bridge    #
####################################
resource "aws_cloudwatch_event_rule" "monthly_schedule" {
  name        = "${module.resource_name_prefix.resource_name}-back-up-monthly-schedule"
  description = "Trigger ${module.resource_name_prefix.resource_name} Request Lambda for monthly backup of minecraft world"
  schedule_expression = "cron(0 12 1 * ? *)"  # Runs at 12:00 PM UTC on the first day of every month
  
  tags = module.tags.tags
}

resource "aws_cloudwatch_event_target" "trigger_lambda" {
  rule      = aws_cloudwatch_event_rule.monthly_schedule.name
  target_id = "TriggerLambdaFunction"
  arn       = module.request_lambda.arn

  input = jsonencode({
    "body": {
      "action"          = "mc_world_archive_start",
      "server_template" = "None",
      "reason"          = "Automated: Event Bridge Trigger for ${var.name} world backup"
    }
  })
}

################################
#   Request Lambda Policy      #
################################
locals {
  request_lambda_s3_iam_policy = "${var.name}-request-lambda-s3"
}
module "request_lambda_s3_iam_policy" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.request_lambda_s3_iam_policy
  description = "IAM Policy for ${var.name} Request Lambda to access various AWS services"

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "ECSFargateAccess"
        Effect = "Allow"
        Action = [
          "ecs:RunTask",
          "ecs:StopTask",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:TagResource",
        ]
        Resource = ["*"] # needs to be replaced once ecs module is done
      },
      {
        Sid = "EC2Access"
        Effect = "Allow"
        Action = ["ec2:DescribeInstances"]
        Resource = "*"
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
      },
      {
        Sid = "S3ListBucketAccess"
        Effect = "Allow"
        Action = ["s3:ListBucket"]
        Resource = [
          module.s3_mc_world.arn,
          module.s3_mc_server_assets.arn
        ]
      }
    ]
  }

  tags = module.tags.tags
}

resource "aws_iam_role_policy_attachment" "request_lambda_s3_iam_policy_role_policy_attachment" {
  role       = module.request_lambda.iam_role_name
  policy_arn = module.request_lambda_s3_iam_policy.policy_arn
}