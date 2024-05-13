########################
#       Naming         #
########################
output "name" {
  description = "The AWS Account ID"
  value       = var.name
}

########################
#     General AWS      #
########################
output "aws_region" {
  description = "The AWS Account ID"
  value       = var.aws_region
}

########################
#         EIP          #
########################
output "eip" {
  value = module.minecraft_server.public_ip
}

########################
#         VPC          #
########################
output "vpc_id" {
  description = "The VPC ID"
  value       = module.vpc.vpc_id
}

output "subnet_id" {
  description = "The Subnet ID"
  value       = module.public_subnet.subnet_ids
}

output "security_group_id" {
  description = "The Subnet ID"
  value       = module.security_group.security_group_id
}

########################
#       S3 Bucket      #
########################
output "s3_mc_world_bucket_name" {
  description = "The name of the Minecraft S3 bucket"
  value       = module.s3_mc_world.name
}

output "mc_s3_bucket_arn" {
  description = "The ARN of the Minecraft S3 bucket"
  value       = module.s3_mc_world.arn
}

output "s3_mc_world_bucket_name_uri" {
  description = "The S3 uri of the minecraft world data"
  value       = module.s3_mc_world.uri
}

output "s3_mc_server_assets_uri" {
  description = "The S3 uri of the minecraft world data"
  value       = module.s3_mc_server_assets.uri
}

########################
#     API Gateway      #
########################
output "api_gateway_url" {
  value = "${module.api_gateway.api_endpoint}"
}

########################
#         EC2          #
########################
output "ec2_key_pair" {
  value = module.ec2_key_pair.key_pair_name
}

output "ssm_ec2_private_key" {
  description = "The private key part of the key pair"
  value       = module.ec2_key_pair.private_key_pem
  sensitive   = true
}

########################
#         Tags         #
########################
output "tags" {
  description = "Label tags"
  value       = module.tags.tags
}

########################
#     Minecraft        #
########################
output "mc_port" {
  description = "Minecraft Server Port"
  value       = var.mc_port
}

########################
#         ECR          #
########################
output "ecr_mc_world_archive_repository_name" {
  value = module.ecr_mc_world_archive.repository_name
}

########################
#         ECS          #
########################
output "ecs_mc_archive_image_arn" {
  value = module.ecs_cluster.ecs_task_definition_container_image
}