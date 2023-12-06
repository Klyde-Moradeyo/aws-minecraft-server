
########################
#          AWS         #
########################
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "eu-west-2"
}

########################
#         Tags         #
########################
variable "tags" {
  description = "Tags from tags module"
  type        = map(string)
}

########################
#     Environment      #
########################
variable "git_branch" {
  description = "The name of the Git branch to use"
  type        = string
}

########################
#    Lambda Function   #
########################
variable "lambda_runtime" {
  description = "Tags from tags module"
  type        = string
}

variable "lambda_timeout" {
  description = "Tags from tags module"
  type        = string
}

variable "lambda_memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime"
  type        = number
  default     = 128 # 128 is Default
}

variable "lambda_reserved_concurrent_executions" {
  description = "The amount of reserved concurrent executions for this lambda function"
  type        = number
  default     = -1 # -1 means no limit
}

variable "lambda_payload_zip_path" {
  description = "Path to the Lambda function payload ZIP file"
  type        = string
}

########################
#    Systems Manager   #
########################
variable "ssm_api_key_name" {
  type        = string
  description = "Name of the SSM parameter to store the API key"
}

########################
#        VPC           #
########################
# variable "security_group_id" {
#   description = "Security group ID"
#   type        = string
# }

# variable "subnet_id" {
#   description = "VPC subnet id to place the instance"
#   type        = string
# }

########################
#     Minecraft        #
########################
variable "mc_server_ip" {
  description = "Minecraft Server Host Name / IP"
  type        = string
}

variable "mc_port" {
  description = "TCP port for minecraft"
  type        = number
  default     = 25565
}

########################
#     EC2 Instance     #
########################
variable "ec2_instance_id" {
  description = "ec2 instance id to target"
  type        = string
}

variable "ec2_instance_arn" {
  description = "ec2 instance arn to target"
  type        = string
}

########################
#    DynamoDB Table    #
########################
variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  type        = string
}

########################
#    Worker Lambda     #
########################
variable "worker_lambda_name" {
  description = "The name of the worker lambda function"
  type        = string
}

variable "worker_lambda_arn" {
  description = "The arn of the worker lambda function"
  type        = string
}

########################
#         ECS          #
########################
variable "ecs_cluster_name" {
  description = "ECS Cluster Name of the environment"
  type        = string
}

variable "ecs_mc_archive_task_definition_name" {
  description = "ECS Task Defintion Namr"
  type        = string
}

variable "mc_archive_task_container_name" {
  description = "ECS Task Container Namr"
  type        = string
}