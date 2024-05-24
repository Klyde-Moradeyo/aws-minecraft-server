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
  family                   = "${module.resource_name_prefix.resource_name}-ecs-task-def"
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = module.execution_role.arn
  task_role_arn            = module.task_role.arn

  # This can be enhanced to support multiple container definitions
  container_definitions = jsonencode([{
    name         = var.container_name
    image        = var.docker_image
    cpu          = var.cpu
    memory       = var.memory
    essential    = var.container_essential
    environment  = var.environment_variables
    secrets      = var.secrets
    portMappings = var.port_mappings
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = module.cloudwatch_log.name
        awslogs-region        = data.aws_region.current.name
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "this" {
  depends_on = [
    aws_ecs_task_definition.this
  ]

  name            = "${module.resource_name_prefix.resource_name}-ecs-service"
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.min_capacity
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition,
    ]
  }
}