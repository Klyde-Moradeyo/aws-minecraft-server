
########################
#    Request Lambda    #
########################
module "request_lambda" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/request-lambda?ref=tf-modules"

  # aws region
  aws_region = var.aws_region

  # Lambda Config
  lambda_runtime          = "python3.10"
  lambda_timeout          = 900
  lambda_memory_size      = 128
  lambda_payload_zip_path = "./request_lambda_latest.zip"

  # IAM
  ec2_instance_arn  = module.minecraft_server.ec2_instance_arn
  worker_lambda_arn = module.worker_lambda.lambda_function_arn

  # Lambda Environment vars
  ec2_instance_id                     = module.minecraft_server.id
  mc_server_ip                        = module.minecraft_server.public_ip
  mc_port                             = var.mc_port
  worker_lambda_name                  = module.worker_lambda.lambda_function_name
  dynamodb_table_name                 = module.dynamodb_table.table_name
  git_branch                          = var.git_branch
  ssm_api_key_name                    = module.ssm_api_gw_key.ssm_parameter_name
  ecs_cluster_name                    = module.ecs_cluster.ecs_cluster_name
  ecs_mc_archive_task_definition_name = module.ecs_cluster.mc_archive_task_definition_name
  ecs_mc_archive_task_container_name  = module.ecs_cluster.mc_archive_task_container_name
  ecs_subnet_id                       = module.public_subnet.subnet_ids[0]
  ecs_security_group_id               = module.security_group.security_group_id
  s3_minecraft_world_bucket_url       = module.s3_mc_world.bucket_uri
  s3_minecraft_assets_bucket_url      = module.s3_mc_server_assets.bucket_uri

  # Module tags
  tags = module.tags.tags
}

# module "request_lambda" {
#   source = "./lambda"

#   function_name = "example-lambda"
#   handler       = "index.handler"
#   runtime       = "python3.10"
#   zip_file      = "./code/index.zip"  # Local ZIP file path (optional)
#   s3_bucket     = "my-lambda-bucket"  # S3 bucket (optional)
#   s3_key        = "lambda/index.zip"  # S3 key (optional)
#   image_uri     = ""                  # Docker image URI (optional)

#   environment = {
#     LOG_LEVEL = "INFO"
#   }

#   permissions = [
#     {
#       action     = "lambda:InvokeFunction"
#       principal  = "s3.amazonaws.com"
#       source_arn = "arn:aws:s3:::my-trigger-bucket/*"
#     }
#   ]

#   tags = module.tags.tags
# }

########################
#     Worker Lambda    #
########################
module "worker_lambda" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/worker-lambda?ref=tf-modules"

  # aws region
  aws_region = var.aws_region

  # Lambda Config
  lambda_runtime          = "python3.10"
  lambda_timeout          = 900
  lambda_memory_size      = 128
  lambda_payload_zip_path = "./worker_lambda_latest.zip"

  # IAM
  ec2_instance_arn    = module.minecraft_server.ec2_instance_arn
  dynamodb_table_name = module.dynamodb_table.table_name

  # Lambda Environment vars
  ssm_git_private_key_name       = var.ssm_git_private_key_name
  ssm_ec2_private_key_name       = module.ssm_mc_server_private_key.ssm_parameter_name
  git_branch                     = var.git_branch
  s3_minecraft_world_bucket_url  = module.s3_mc_world.bucket_arn
  s3_minecraft_assets_bucket_url = module.s3_mc_server_assets.bucket_uri
  api_gateway_url                = "${module.api_gateway.api_gateway_url}/${module.api_gateway.stage_name}"
  ssm_api_key_name               = module.ssm_api_gw_key.ssm_parameter_name

  # Module tags
  tags = module.tags.tags
}