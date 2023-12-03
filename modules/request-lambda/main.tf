########################
#   Resource Naming    #
########################
module "resource_naming" {
  source = "../resource-naming"
  tags   = var.tags
}

########################
#    Lambda Function   #
########################
resource "aws_lambda_function" "lambda_function" {
  filename                       = var.lambda_payload_zip_path
  source_code_hash               = filebase64sha256(var.lambda_payload_zip_path)
  function_name                  = "${module.resource_naming.name}-lambda"
  role                           = aws_iam_role.iam_for_lambda.arn
  handler                        = "lambda_function.lambda_handler"
  runtime                        = var.lambda_runtime
  timeout                        = var.lambda_timeout
  memory_size                    = var.lambda_memory_size
  reserved_concurrent_executions = var.lambda_reserved_concurrent_executions

  environment {
    variables = {
      MC_SERVER_IP                  = var.mc_server_ip
      MC_PORT                       = var.mc_port
      EC2_INSTANCE_ID               = var.ec2_instance_id
      WORKER_LAMBDA_NAME            = var.worker_lambda_name
      DYNAMO_DB_TABLE_NAME          = var.dynamodb_table_name
      SSM_REQUEST_LAMBDA_AUTH_TOKEN = "/${var.ssm_api_key_name}"
      TAGS_JSON                     = jsonencode(var.tags)
    }
  }

  tags = var.tags
}


# resource "aws_lambda_layer_version" "terraform_lambda_layer" {
#   filename   = "${path.module}/../../lambda/terraform_layer.zip"  # Replace with your layer ZIP filename
#   layer_name = "terraform_lambda_layer"
#   compatible_runtimes = [ "python3.8" ]  # Replace with your desired runtime
# }

