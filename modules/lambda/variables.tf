########################
#         Tags         #
########################

variable "label_id" {
  description = "ID from tags module"
  type        = string
}

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

########################
#    Systems Manager   #
########################
variable "bot_command_name" {
  description = "SSM Store Containing the Command Fargate should run"
  type        = string
}

variable "terraform_token_name" {
  description = "Terraform token name in Systems Manager Parameter Store"
  type        = string
}

variable "git_private_key_name" {
  description = "Private Key name for Github SSH in Systems Manager Parameter Store"
  type        = string
}

variable "ec2_private_key_name" {
  description = "Private Key name for EC2 in Systems Manager Parameter Store"
  type        = string
}

########################
#        VPC           #
########################
variable "security_group_id" {
  description = "Security group ID"
  type        = string
}

variable "subnet_id" {
  description = "VPC subnet id to place the instance"
  type        = string
}

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

variable "ec2_instance_id" {
  description = "ec2 instance id to target"
  type = string
}

variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "eu-west-2"
}







