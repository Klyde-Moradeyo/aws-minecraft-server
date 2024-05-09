##########################
#     Naming Config      #
##########################
module "resource_name_prefix" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/resource-name-prefix/aws"
  version = "0.0.1"

  name = var.name
  tags = var.tags
}

#############################
#    ECS Task Definition    #
#############################
resource "aws_ecs_task_definition" "this" {
  family                   = var.family
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities
  cpu                      = var.cpu
  memory                   = var.memory
  tags                     = var.tags

  container_definitions = jsonencode(var.container_definitions)

  # Placement Constraints
  dynamic "placement_constraints" {
    for_each = var.placement_constraints
    content {
      type       = placement_constraints.value.type
      expression = placement_constraints.value.expression
    }
  }

  # Volumes
  dynamic "volume" {
    for_each = var.volumes
    content {
      name      = volume.value.name
      host_path = volume.value.host_path
    }
  }

  # Inference Accelerators
  dynamic "inference_accelerator" {
    for_each = var.inference_accelerators
    content {
      device_name = inference_accelerator.value.device_name
      device_type = inference_accelerator.value.device_type
    }
  }

  # Optional attributes
  ipc_mode = var.ipc_mode != null ? var.ipc_mode : null
  pid_mode = var.pid_mode != null ? var.pid_mode : null

  dynamic "proxy_configuration" {
    for_each = var.proxy_configuration != null ? [var.proxy_configuration] : []
    content {
      type            = proxy_configuration.value.type
      container_name  = proxy_configuration.value.container_name
      properties      = proxy_configuration.value.properties
    }
  }
}
