
########################
#     General AWS      #
########################
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "eu-west-1"
}

########################
#        tags          #
########################
variable "project" {
  description = "The name of the project"
  type        = string
  default     = "personal-mincecraft-server"
}

variable "client" {
  description = "The client for the project"
  type        = string
  default     = "Klyde-Moradeyo"
}

variable "owner" {
  description = "The owner of the project"
  type        = string
  default     = "Klyde-Moradeyo"
}

variable "namespace" {
  description = "Logical grouping for resources, such as by service"
  type        = string
  default     = "minecrasft"
}

variable "environment" {
  description = "The project environment"
  type        = string
  default     = "prod"
}

########################
#     Environment      #
########################
variable "git_branch" {
  description = "The name of the Git branch to use"
  type        = string
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

variable "ssm_git_private_key_name" {
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

  ### T3a Family ###
  # default = 	"t3a.large"

  ### T4g Family ###
  # default = "t4g.medium"
  # default = "t4g.xlarge"

  ### R6g Family ###
  # default = "r6g.medium"
  # default = "r6i.large" 
  # default = "r6i.xlarge"
  # default = "r6i.2xlarge"

  ### Z1d Family ###
  # default = "z1d.large"
  # default = "z1d.xlarge"
  # default = "z1d.2xlarge"

  ### M5zn Family ###
  default = "m5zn.xlarge"

  // https://amazon-aws-ec2-pricing-comparison.pcapps.com/
}

variable "ami" {
  type = list(string)
  # default = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  default = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
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
  type = list(string)
  # default = ["arm64"]
  default = ["x86_64"]
}

variable "network_interface_id" {
  type    = string
  default = "network_id_from_aws"
}


########################
#        VPC           #
########################
variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

########################
#        Subnet        #
########################
variable "public_subnet_cidrs" {
  description = "The CIDR block for the public Subnet."
  type        = list(string)
  default = [
    "10.0.51.0/24",
    "10.0.52.0/24",
    "10.0.53.0/24"
  ]
}

########################
#   Security Groups    #
########################
variable "allowed_cidrs" {
  description = "Allow these CIDR blocks to the server - default is the Universe"
  type        = string
  default     = "0.0.0.0/0" // https://cidr.xyz/
}






