########################
#         ECS          #
########################
output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.my_cluster.name
}

output "ecs_task_definition_family" {
  description = "The family of the ECS task definition"
  value       = aws_ecs_task_definition.my_task.family
}

output "mc_archive_task_container_name" {
  description = "The name of the container in the ECS task definition"
  value       = jsondecode(aws_ecs_task_definition.my_task.container_definitions)[0].name
}

output "ecs_task_definition_container_image" {
  description = "The image URL of the container in the ECS task definition"
  value       = jsondecode(aws_ecs_task_definition.my_task.container_definitions)[0].image
}

output "mc_archive_task_definition_name" {
  description = "The name of the ECS Task Definition"
  value       = aws_ecs_task_definition.my_task.family
}
