########################
#   Resource Naming    #
########################
module "resource_naming" {
  source = "../resource-naming"
  tags   = var.tags
}


data "aws_caller_identity" "aws" {}

locals {
  cluster_name   = "${module.resource_naming.name}-cluster"
  container_name = "${module.resource_naming.name}-world-archiver"
}

########################
#         ECS          #
########################
resource "aws_ecs_cluster" "my_cluster" {
  name = local.cluster_name
  tags = var.tags
}

resource "aws_ecs_task_definition" "my_task" {
  family                   = local.container_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  cpu    = var.task_cpu_limit
  memory = var.task_memory_limit

  container_definitions = jsonencode([{
    name      = local.container_name
    image     = "${data.aws_caller_identity.aws.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.mc_archive_ecr_repo_name}:latest"
    cpu       = var.task_cpu_limit
    memory    = var.task_memory_limit
    essential = true
    portMappings = [
      {
        containerPort = 8080
        protocol      = "tcp"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/${local.cluster_name}"
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])

  tags = var.tags
}

