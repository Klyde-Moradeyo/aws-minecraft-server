module "request_lambda" {
  source  = "./lambda"

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
      DYNAMO_DB_TABLE_NAME                = module.dynamodb_table.table_name
      SSM_REQUEST_LAMBDA_AUTH_TOKEN       = "/${module.ssm_api_gw_key.ssm_parameter_name}"
      ECS_CLUSTER_NAME                    = module.ecs_cluster.ecs_cluster_name
      ECS_MC_ARCHIVE_TASK_DEFINITION_NAME = module.ecs_cluster.mc_archive_task_definition_name
      ECS_MC_ARCHIVE_CONTAINER_NAME       = module.ecs_cluster.mc_archive_task_container_name
      S3_MC_WORLD_URI                     = module.s3_mc_world.bucket_uri
      S3_MC_ASSETS_URI                    = module.s3_mc_server_assets.bucket_uri
      ECS_SUBNET_ID                       = module.public_subnet.subnet_ids[0]
      ECS_SECURITY_GROUP_ID               = module.security_group.security_group_id
      TAGS_JSON                           = jsonencode(module.tags.tags)
    }

  tags = module.tags.tags
}

module "worker_lambda" {
  source  = "./lambda"

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
      SSM_EC2_PRIVATE_KEY           = "/${module.ssm_mc_server_private_key.ssm_parameter_name}"
      GIT_BRANCH                    = var.git_branch
      S3_MC_WORLD_URI               = module.s3_mc_world.bucket_arn
      S3_MC_ASSETS_URI              = module.s3_mc_server_assets.bucket_uri
      API_GW_URL                    = "${module.api_gateway.api_gateway_url}/${module.api_gateway.stage_name}"
      SSM_REQUEST_LAMBDA_AUTH_TOKEN = "/${module.ssm_api_gw_key.ssm_parameter_name}"
    }

  layers = [
    local.git_lambda_layer_arn
  ]

  # Optional Permissions
  permissions = [
    {
      action     = "lambda:InvokeFunction"
      principal  = "lambda.amazonaws.com"
      source_arn = module.request_lambda.arn
    }
  ]

  reserved_concurrent_executions = 1

  tags = module.tags.tags
}

locals {
  git_lambda_layer_arn = "arn:aws:lambda:${var.aws_region}:553035198032:layer:git-lambda2:8"
}