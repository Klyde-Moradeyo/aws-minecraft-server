output "task_definition_arn" {
  value       = aws_ecs_task_definition.task_definition.arn
  description = "ARN of the ECS task definition."
}

output "task_definition_name" {
  value       = aws_ecs_task_definition.task_definition.family
  description = "The name of the ECS task definition."
}

output "ecs_service_name" {
  value       = length(aws_ecs_service.this) > 0 ? aws_ecs_service.this[0].name : ""
  description = "Name of the ECS service, if created."
}

output "ecs_service_id" {
  value       = length(aws_ecs_service.this) > 0 ? aws_ecs_service.this[0].id : ""
  description = "ID of the ECS service, if created."
}

output "ecs_service_network_configuration" {
  value = length(aws_ecs_service.this) > 0 ? {
    subnets          = aws_ecs_service.this[0].network_configuration[0].subnets
    security_groups  = aws_ecs_service.this[0].network_configuration[0].security_groups
    assign_public_ip = aws_ecs_service.this[0].network_configuration[0].assign_public_ip
  } : {
    subnets          = []
    security_groups  = []
    assign_public_ip = false
  }
  description = "Network configuration for the ECS service, if created."
}

output "autoscaling_target_id" {
  value       = length(aws_appautoscaling_target.ecs_target) > 0 ? aws_appautoscaling_target.ecs_target[0].id : ""
  description = "ID of the autoscaling target."
}

output "active_scaling_policies" {
  value       = [for policy in aws_appautoscaling_policy.ecs_policy : policy.id]
  description = "List of active scaling policy IDs attached to the ECS service."
}

output "container_definitions_json" {
  value = jsonencode(
    tomap({
      for container in jsondecode(aws_ecs_task_definition.task_definition.container_definitions) : container.name => container
    })
  )
  description = "JSON string of the container definitions used in the task."
}

output "task_definition_family_revision" {
  value       = "${aws_ecs_task_definition.task_definition.family}:${aws_ecs_task_definition.task_definition.revision}"
  description = "Family and revision of the ECS task definition."
}

output "cloudwatch_log_group_names" {
  value       = [for container in var.containers : "/ecs/${container.name}"]
  description = "CloudWatch log group names for the containers."
}

output "task_role_arn" {
  description = "The IAM Task role for the Task Definition."
  value       = module.task_role.iam_role_arn
}

output "task_role_name" {
  description = "The IAM Task role for the Task Definition."
  value       = module.task_role.iam_role_name
}

output "execution_role_arn" {
  description = "The IAM Execution role for the Task Definition."
  value       = module.execution_role.iam_role_arn
}

output "execution_role_name" {
  description = "The IAM Execution role for the Task Definition."
  value       = module.execution_role.iam_role_name
}