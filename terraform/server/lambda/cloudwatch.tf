module "cloudwatch_log" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/cloudwatch-log-group/aws"
  version = "0.0.1"

    name = "/aws/lambda/${var.name}"
    retention_in_days = 30
    tags = var.tags
}