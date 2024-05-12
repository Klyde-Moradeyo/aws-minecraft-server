locals {
  git_lambda_layer_arn = "arn:aws:lambda:${var.aws_region}:553035198032:layer:git-lambda2:8"
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
      API_GW_URL                    = "${module.api_gateway.api_endpoint}"
    }

  layers = [
    local.git_lambda_layer_arn
  ]

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