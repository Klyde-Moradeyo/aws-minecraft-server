
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
variable "ssm_git_private_key_name" {
  description = "Private Key name for Github SSH in Systems Manager Parameter Store"
  type        = string
}

variable "ssm_ec2_private_key_name" {
  description = "Private Key name for EC2 in Systems Manager Parameter Store"
  type        = string
}

variable "ssm_api_key_name" {
  type        = string
  description = "Name of the SSM parameter to store the API key"
}

########################
#        API           #
########################
variable "api_gateway_url" {
  type        = string
  description = "URL of the API Gateway"
}

########################
#     EC2 Instance     #
########################
variable "ec2_instance_arn" {
  description = "ec2 instance arn to target"
  type        = string
}

########################
#       S3 Bucket      #
########################
variable "s3_minecraft_world_bucket_url" {
  description = "Minecraft world bucket URI"
  type        = string
}

variable "s3_minecraft_assets_bucket_url" {
  description = "Minecraft assets bucket URI"
  type        = string
}

########################
#    DynamoDB Table    #
########################
variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  type        = string
}