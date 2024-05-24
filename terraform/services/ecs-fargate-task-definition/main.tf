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
resource "aws_ecs_task_definition" "task_definition" {
  family                   = "${module.resource_name_prefix.resource_name}-ecs-task-def"
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = module.execution_role.iam_role_arn
  task_role_arn            = module.task_role.iam_role_arn

  container_definitions = jsonencode([for container in var.containers : {
    name         = container.name
    image        = container.image
    cpu          = container.cpu
    memory       = container.memory
    essential    = container.essential
    environment  = container.environment_variables
    secrets      = container.secrets
    portMappings = container.port_mappings
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/${container.name}"
        awslogs-region        = data.aws_region.current.name
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "this" {
  depends_on = [
    aws_ecs_task_definition.task_definition
  ]

  name            = "${module.resource_name_prefix.resource_name}-ecs-service"
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = var.min_capacity
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = var.assign_public_ip
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition,
    ]
  }
}