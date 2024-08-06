##########################
#        Lambda          #
##########################
module "request_lambda" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/lambda/aws"
  version = "0.0.5"

  name        = "${var.name}-request"
  handler     = "lambda_function.lambda_handler"
  runtime     = "python3.10"
  description = "Lambda Function to handle requests to the ${var.name} api"
  timeout     = 900
  memory_size = 128
  publish     = true

  zip_file = "request_lambda_latest.zip"

  environment = {
    MC_SERVER_IP                        = module.minecraft_server.public_ip
    MC_PORT                             = var.mc_port
    EC2_INSTANCE_ID                     = module.minecraft_server.id
    WORKER_LAMBDA_NAME                  = module.worker_lambda.name
    DYNAMO_DB_TABLE_NAME                = module.dynamodb.name
    ECS_CLUSTER_NAME                    = module.ecs_cluster.name
    ECS_MC_ARCHIVE_TASK_DEFINITION_NAME = module.ecs_task_definition.task_definition_name
    ECS_MC_ARCHIVE_CONTAINER_NAME       = local.mc_archive_world_container_name
    ECS_SUBNET_ID                       = module.public_subnet.subnet_ids[0]
    TAGS_JSON                           = jsonencode(module.tags.tags)
  }

  permissions = [
    {
      statement_id = "${module.resource_name_prefix.resource_name}-allow-event-bridge-invoke"
      action       = "lambda:InvokeFunction"
      principal    = "events.amazonaws.com"
      source_arn   = aws_cloudwatch_event_rule.monthly_schedule.arn
    },
    {
      statement_id = "${module.resource_name_prefix.resource_name}-allow-api-gateway-invoke"
      action       = "lambda:InvokeFunction"
      principal    = "apigateway.amazonaws.com"
      source_arn   = module.api_gateway.execution_arn
    }
  ]

  log_retention_in_days = 30

  iam_role_policy_arns = {
    (local.request_lambda_iam_policy)                  = module.request_lambda_iam_policy.policy_arn
    (local.request_lambda_ecs_iam_policy)              = module.request_lambda_ecs_iam_policy.policy_arn
    (local.request_lambda_invoke_worker_lambda_policy) = module.request_lambda_invoke_worker_lambda_policy.policy_arn
  }

  tags = module.tags.tags
}

####################################
# Request Lambda CloudWatch Alarm  #
####################################
module "request_lambda_error_alarm" {
  source = "./module/cloudwatch-alarm"

  name                = "${var.name}-request-lambda-errors"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 60
  threshold           = 0 # Trigger the alarm if there is at least 1 error

  alarm_actions             = [module.sns.arn]
  ok_actions                = [module.sns.arn]
  insufficient_data_actions = [module.sns.arn]

  dimensions = [
    {
      name  = "FunctionName"
      value = module.request_lambda.name
    }
  ]

  tags = module.tags.tags
}


####################################
#   Request Lambda Event Bridge    #
####################################
resource "aws_cloudwatch_event_rule" "monthly_schedule" {
  name                = "${module.resource_name_prefix.resource_name}-back-up-monthly-schedule"
  description         = "Trigger ${module.resource_name_prefix.resource_name} Request Lambda for monthly backup of minecraft world"
  schedule_expression = "cron(0 12 1 * ? *)" # Runs at 12:00 PM UTC on the first day of every month

  tags = module.tags.tags
}

resource "aws_cloudwatch_event_target" "trigger_lambda" {
  rule      = aws_cloudwatch_event_rule.monthly_schedule.name
  target_id = "TriggerLambdaFunction"
  arn       = module.request_lambda.arn

  input = jsonencode({
    "body" : {
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
  request_lambda_iam_policy                  = "${var.name}-request-lambda-dynamodb-s3"
  request_lambda_ecs_iam_policy              = "${var.name}-request-lambda-ecs"
  request_lambda_invoke_worker_lambda_policy = "${var.name}-request-lambda-invoke-worker-lambda"
}

module "request_lambda_ecs_iam_policy" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.request_lambda_ecs_iam_policy
  description = "IAM Policy for ${var.name} Request Lambda to access ECS"

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECSFargateAccess"
        Effect = "Allow"
        Action = [
          "ecs:StopTask",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:TagResource",
        ]
        Resource = ["*"]
      },
      {
        Sid    = "ECSTaskRunLimit"
        Effect = "Allow"
        Action = [
          "ecs:RunTask",
        ]
        Resource = [
          module.ecs_task_definition.task_definition_arn
        ],
        Condition = {
          "ForAllValues:StringEquals" : {
            "ecs:cluster" : module.ecs_cluster.arn
          }
        }
      },
      {
        Sid    = "IAMPassRole"
        Effect = "Allow"
        Action = [
          "iam:PassRole",
        ]
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecs/${var.name}-*-role"
        ]
      }
    ]
  }

  tags = module.tags.tags
}

module "request_lambda_iam_policy" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.request_lambda_iam_policy
  description = "IAM Policy for ${var.name} Request Lambda to access various AWS services"

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EC2Access"
        Effect   = "Allow"
        Action   = ["ec2:DescribeInstances"]
        Resource = "*"
      },
      {
        Sid    = "DynamoDBAccess"
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
        Sid    = "S3ListBucketAccess"
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

module "request_lambda_invoke_worker_lambda_policy" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.request_lambda_invoke_worker_lambda_policy
  description = "IAM Policy for ${var.name} Request Lambda to Allow Request Lambda Invoke the Worker Lambda"

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowRequestLambdaInvoke"
        Effect   = "Allow",
        Action   = "lambda:InvokeFunction",
        Resource = module.worker_lambda.arn
      }
    ]
  }

  tags = module.tags.tags
}