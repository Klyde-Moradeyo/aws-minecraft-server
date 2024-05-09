output "arn" {
  description = "The ARN of the created task definition"
  value       = aws_ecs_task_definition.this.arn
}
