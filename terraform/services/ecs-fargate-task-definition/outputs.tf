output "ecs_task_definition_arn" {
  value       = aws_ecs_task_definition.this.arn
  description = "ARN of the ECS task definition."
}

output "ecs_service_name" {
  value       = aws_ecs_service.this.name
  description = "Name of the ECS service."
}


output "iam_role_arn" {
  description = "The IAM role for the Lambda function."
  value       = module.iam_role.iam_role_arn
}

output "iam_role_name" {
  description = "The IAM role for the Lambda function."
  value       = module.iam_role.iam_role_name
}
