
########################
#     General AWS      #
########################
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "eu-west-2"
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
  default     = "python3.10"
}

variable "lambda_timeout" {
  description = "Timeout for Lambda execution"
  type        = number
  default     = 900 # Set the timeout to the max (15 minutes)
}

########################
#     Minecraft        #
########################
variable "mc_port" {
  description = "TCP port for minecraft"
  type        = number
  default     = 25565
}

# variable "mc_backup_freq" {
#   description = "How often (mins) to sync to S3"
#   type        = number
#   default     = 5
# }

########################
#    Systems Manager   #
########################
variable "bot_command_name" {
  description = "SSM Store Containing the Command Fargate should run"
  type        = string
  default     = "mc_server/BOT_COMMAND"
}

variable "terraform_token_name" {
  description = "Terraform token name in Systems Manager Parameter Store"
  type        = string
  default     = "terraform-cloud-user-api"
}

variable "git_private_key_name" {
  description = "Private Key name for Github SSH in Systems Manager Parameter Store"
  type        = string
  default     = "dark-mango-bot-private-key"
}

########################
#       AWS EC2        #
########################
variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t4g.nano"
  # default = "t4g.small" 
  # default = "t4g.2xlarge" 
  # default = "t4g.xlarge" 
  // For tests: default =  "t2.medium" | https://amazon-aws-ec2-pricing-comparison.pcapps.com/
}

variable "ami" {
  type    = list(string)
  default = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
}

variable "ami_owners" {
  description = "The AWS account IDs of the AMI owners."
  type        = list(string)
  default     = ["099720109477"]
}

variable "ami_root_device_type" {
  description = "The type of root device used by the AMI."
  type        = list(string)
  default     = ["ebs"]
}

variable "ami_virtualization_type" {
  description = "The virtualization type of the AMI."
  type        = list(string)
  default     = ["hvm"]
}

variable "architecture" {
  type    = list(string)
  default = ["arm64"]
}

variable "network_interface_id" {
  type    = string
  default = "network_id_from_aws"
}

########################
#   Security Groups    #
########################
variable "allowed_cidrs" {
  description = "Allow these CIDR blocks to the server - default is the Universe"
  type        = string
  default     = "0.0.0.0/0" // https://cidr.xyz/
}






