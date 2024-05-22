module "cloudwatch_log" {
  # source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/cloudwatch-log-group/aws"
  # version = "0.0.1"
  source = "../cloudwatch-log-group"

  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}