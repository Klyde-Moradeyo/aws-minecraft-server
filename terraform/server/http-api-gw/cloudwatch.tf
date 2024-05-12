module "cloudwatch_log" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/cloudwatch-log-group/aws"
  version = "0.0.1"

  for_each = {
    for k, v in var.stages : k => v if v.logging != null && v.logging.enabled
  }

  name              = "/aws/apigateway/${each.key}-stage/${var.name}"
  retention_in_days = each.value.logging.retention_days
  tags = var.tags
}