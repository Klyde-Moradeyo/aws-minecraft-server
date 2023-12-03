########################
#   Resource Naming    #
########################
module "resource_naming" {
  source = "../resource-naming"
  tags   = var.tags
}

data "aws_caller_identity" "current" {}

########################
#    Lambda Function   #
########################
resource "aws_lambda_function" "lambda_function" {
  filename                       = var.lambda_payload_zip_path
  source_code_hash               = filebase64sha256(var.lambda_payload_zip_path)
  function_name                  = "${module.resource_naming.name}-worker-lambda"
  role                           = aws_iam_role.iam_for_lambda.arn
  handler                        = "lambda_function.lambda_handler"
  runtime                        = var.lambda_runtime
  timeout                        = var.lambda_timeout
  memory_size                    = var.lambda_memory_size
  reserved_concurrent_executions = var.lambda_reserved_concurrent_executions

  environment {
    variables = {
      SSM_GIT_PRIVATE_KEY           = "/${var.ssm_git_private_key_name}"
      SSM_EC2_PRIVATE_KEY           = "/${var.ssm_ec2_private_key_name}"
      GIT_BRANCH                    = var.git_branch
      S3_MC_WORLD_URI               = var.s3_minecraft_world_bucket_url
      S3_MC_ASSETS_URI              = var.s3_minecraft_assets_bucket_url
      API_GW_URL                    = var.api_gateway_url
      SSM_REQUEST_LAMBDA_AUTH_TOKEN = "/${var.ssm_api_key_name}"
    }
  }

  layers = [
    local.git_lambda_layer_arn
  ]

  tags = var.tags
}

########################
#     Lambda Layer     #
########################
locals {
  git_lambda_layer_arn = "arn:aws:lambda:${var.aws_region}:553035198032:layer:git-lambda2:8"
}

# resource "aws_lambda_layer_version" "terraform_lambda_layer" {
#   filename   = "${path.module}/../../lambda/terraform_layer.zip"  # Replace with your layer ZIP filename
#   layer_name = "terraform_lambda_layer"
#   compatible_runtimes = [ "python3.8" ]  # Replace with your desired runtime
# }

