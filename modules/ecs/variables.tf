########################
#         Tags         #
########################
variable "tags" {
  description = "Tags from labels module"
  type        = map(string)
}

########################
#         AWS          #
########################
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
}

########################
#         ECS          #
########################
variable "task_cpu_limit" {
  description = "CPU Resource limit for container level and task level"
  type        = number
}

variable "task_memory_limit" {
  description = "Memory Resource limit for container and task level"
  type        = string
}

########################
#    Systems Manager   #
########################
variable "ssm_git_private_key_name" {
  description = "Private Key name for Github SSH in Systems Manager Parameter Store"
  type        = string
}

########################
#         IAM          #
########################
variable "minecraft_world_s3_bucket" {
  description = "S3 Bucket arns that the fargate container requires access to"
  type        = string
}

variable "minecraft_assets_s3_bucket" {
  description = "S3 Bucket arns that the fargate container requires access to"
  type        = string
}
