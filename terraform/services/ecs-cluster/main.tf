##########################
#     Naming Config      #
##########################
module "resource_name_prefix" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/resource-name-prefix/aws"
  version = "0.0.1"

  name = var.name
  tags = var.tags
}

########################
#     ECS Cluster      #
########################
resource "aws_ecs_cluster" "cluster" {
  name = "${module.resource_name_prefix.resource_name}-cluster"

  setting {
    name  = "containerInsights"
    value = var.container_insights ? "enabled" : "disabled"
  }

  tags = var.tags
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  count            = length(var.capacity_providers) > 0 ? 1 : 0
  cluster_name     = aws_ecs_cluster.cluster.id
  capacity_providers = var.capacity_providers

  dynamic "default_capacity_provider_strategy" {
    for_each = length(var.default_capacity_provider_strategy) > 0 ? var.default_capacity_provider_strategy : []

    content {
      capacity_provider = default_capacity_provider_strategy.value.capacity_provider
      weight            = default_capacity_provider_strategy.value.weight
      base              = default_capacity_provider_strategy.value.base
    }
  }
}

