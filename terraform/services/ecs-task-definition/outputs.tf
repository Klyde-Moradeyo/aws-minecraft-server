output "arn" {
  description = "The ARN of the created task definition"
  value       = aws_ecs_task_definition.this.arn
}

output "iam_role_arn" {
  description = "The IAM role for the Lambda function."
  value       = module.iam_role.iam_role_arn
}

output "iam_role_name" {
  description = "The IAM role for the Lambda function."
  value       = module.iam_role.iam_role_name
}
