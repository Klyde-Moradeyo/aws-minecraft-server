module "cloudwatch_log" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/cloudwatch-log-group/aws"
  version = "0.0.1"

  name = "/aws/api_gateway/${local.api_name}"
  retention_in_days = var.log_retention_days
  tags = var.tags
}

resource "aws_api_gateway_account" "account" {
  cloudwatch_role_arn = module.iam_role.arn
}
