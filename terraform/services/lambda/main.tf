##########################
#     Naming Config      #
##########################
module "resource_name_prefix" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/resource-name-prefix/aws"
  version = "0.0.1"

  name = var.name
  tags = var.tags
}

##########################
#        Lambda          #
##########################
resource "aws_lambda_function" "lambda" {
  function_name = "${module.resource_name_prefix.resource_name}-lambda"
  handler       = var.handler != "" ? var.handler : null
  runtime       = var.runtime != "" ? var.runtime : null
  role          = module.iam_role.iam_role_arn
  description   = var.description
  timeout       = var.timeout
  memory_size   = var.memory_size
  publish       = var.publish

  # Environment variables (optional)#
  dynamic "environment" {
    for_each = var.environment != {} ? [var.environment] : []
    content {
      variables = var.environment
    }
  }

  layers = var.layers

  # Reserved concurrent executions
  reserved_concurrent_executions = var.reserved_concurrent_executions

  # Source configurations
  s3_bucket = var.s3_bucket != "" ? var.s3_bucket : null
  s3_key    = var.s3_key != "" ? var.s3_key : null
  filename  = var.zip_file != "" ? var.zip_file : null
  image_uri = var.image_uri != "" ? var.image_uri : null
  source_code_hash = (
    var.zip_file != "" ? filebase64sha256(var.zip_file) :
    var.s3_file_hash != "" ? var.s3_file_hash : null
  )

  logging_config {
    log_format            = var.log_format
    log_group             = module.cloudwatch_log.name
    application_log_level = var.log_format == "JSON" ? var.application_log_level: null
    system_log_level      = var.log_format == "JSON" ? var.system_log_level: null
  }

  tags = var.tags
}

# Set permissions (optional)
resource "aws_lambda_permission" "permission" {
  count         = length(var.permissions)
  statement_id  = element(var.permissions, count.index)["statement_id"]
  action        = element(var.permissions, count.index)["action"]
  principal     = element(var.permissions, count.index)["principal"]
  source_arn    = element(var.permissions, count.index)["source_arn"]
  function_name = aws_lambda_function.lambda.function_name
}