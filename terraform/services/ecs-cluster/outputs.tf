output "id" {
  description = "The ID of the ECS cluster."
  value       = aws_ecs_cluster.cluster.id
}

output "arn" {
  description = "The ARN of the ECS cluster."
  value       = aws_ecs_cluster.cluster.arn
}

output "name" {
  description = "The name of the ECS cluster."
  value       = aws_ecs_cluster.cluster.name
}