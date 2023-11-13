data "aws_caller_identity" "aws" {}

locals {
  container_definition_name = "${var.label_id}-${var.ecr_repo_name}"
}

########################
#         ECS          #
########################
resource "aws_ecs_cluster" "my_cluster" {
  name = "${var.label_id}-cluster"
  tags = var.label_tags
}

resource "aws_ecs_task_definition" "my_task" {
  family                = "${var.label_id}-task-definition"
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn         = aws_iam_role.ecs_task_execution_role.arn

  # Task Level Resource Limits
  cpu                   = var.ecs_cpu_limit
  memory                = var.ecs_memory_limit

  # Container level definition
  container_definitions = <<DEFINITION
  [
    {
      "name": "${local.container_definition_name}",
      "image": "${data.aws_caller_identity.aws.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${local.container_definition_name}:latest",
      "cpu": ${var.ecs_cpu_limit},
      "memory": ${var.ecs_memory_limit},
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.mc_port},
          "protocol": "tcp"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/${local.container_definition_name}",
          "awslogs-region": "${var.aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
  DEFINITION

  tags = var.label_tags
}

# ECS Service (with public IP assignment)
resource "aws_ecs_service" "my_service" {
  name            = "${var.label_id}-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets = var.public_subnet_ids
    assign_public_ip = true
    security_groups = [aws_security_group.my_sg.id]
  }

  desired_count = var.desired_count
  tags          = var.label_tags
}

