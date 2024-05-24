locals {
  cluster_name = split("/", element(split(":", var.cluster_arn), 5))[1]
}

module "cloudwatch_log" {
  # source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/cloudwatch-log-group/aws"
  # version = "0.0.2"
  source = "../cloudwatch-log-group"
  for_each          = { for container in var.containers : container.name => container }
  
  name              = "/ecs/${local.cluster_name}/${each.key}"
  retention_in_days = var.log_retention_in_days

  tags = var.tags
}