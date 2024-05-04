
########################
#     General AWS      #
########################
# output "aws_account_id" {
#   description = "The AWS Account ID"
#   value       = data.aws_caller_identity.aws.account_id
# }

########################
#         EIP          #
########################
output "eip" {
  value = module.eip.eip_public_ip
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
  value       = module.vpc.subnet_id
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
  value       = module.s3_mc_world.s3_bucket_name
}

output "mc_s3_bucket_arn" {
  description = "The ARN of the Minecraft S3 bucket"
  value       = module.s3_mc_world.s3_bucket_arn
}

output "s3_mc_world_bucket_name_uri" {
  description = "The S3 uri of the minecraft world data"
  value       = module.s3_mc_world.s3_bucket_uri
}

output "s3_mc_server_assets_uri" {
  description = "The S3 uri of the minecraft world data"
  value       = module.s3_mc_server_assets.s3_bucket_uri
}

# output "mc_archive_s3_bucket_uri" {
#   description = "The name of the S3 bucket for logs"
#   value       = "WIP --- s3://${aws_s3_bucket.mc_s3.id}"
# }

# output "mc_archive_s3_bucket_arn" {
#   description = "The S3 uri of the minecraft world data"
#   value       = "module.s3_mc_world.s3_bucket_uri"
# }

########################
#     API Gateway      #
########################
output "api_gateway_url" {
  value = "${module.api_gateway.api_gateway_url}/${module.api_gateway.stage_name}"
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
output "label_id" {
  description = "Label ID"
  value       = module.tags.label_id
}

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
  value = module.mc_world_archive_ecr_registry.ecr_repository_name
}

output "ecr_mc_monitoring_repository_name" {
  value = module.mc_monitoring_ecr_registry.ecr_repository_name
}

########################
#         ECS          #
########################
output "ecs_mc_archive_image_arn" {
  value = module.ecs_cluster.ecs_task_definition_container_image
}