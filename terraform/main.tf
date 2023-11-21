########################
#       tags         #
########################
module "tags" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/tags?ref=tf-modules"

  environment = var.git_branch
}

########################
#        VPC           #
########################
module "vpc" {
  source       = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/vpc?ref=tf-modules"
  vpc_cidr     = "10.0.0.0/16"
  subnet_cidrs = "10.0.2.0/24"
  tags         = module.tags.tags
}

module "security_group" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/security-group?ref=tf-modules"

  vpc_id = module.vpc.vpc_id
  tags   = module.tags.tags

  ingress_rules = [
    {
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = [var.allowed_cidrs]
      ipv6_cidr_blocks = []
      description      = "SSH access from anywhere"
    },
    {
      from_port        = var.mc_port
      to_port          = var.mc_port
      protocol         = "tcp"
      cidr_blocks      = [var.allowed_cidrs]
      ipv6_cidr_blocks = []
      description      = "Minecraft Server Port"
    }
    # Promtheus Metrics
    # {
    #   from_port   = 9090
    #   to_port     = 9090
    #   protocol    = "tcp"
    #   cidr_blocks = [var.allowed_cidrs]
    #   ipv6_cidr_blocks = []
    #   description = "Minecraft Server Port"
    # }
  ]

  egress_rules = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      description      = "Allow all outbound traffic"
    },
  ]
}

########################
#         EIP          #
########################
module "eip" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/eip?ref=tf-modules"

  # Module tags
  tags = module.tags.tags
}

########################
#     EC2 Key Pair     #
########################
module "ec2_key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "2.0.2"

  key_name           = "${module.tags.label_id}-key"
  create_private_key = true
}

########################
#    Systems Manager   #
########################
module "ssm_mc_server_private_key" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/ssm?ref=tf-modules"

  parameter_name = "mc_server/private_key"
  parameter_type = "SecureString"
  value          = module.ec2_key_pair.private_key_pem

  # Module tags
  label_id = module.tags.label_id
  tags     = module.tags.tags
}

module "ssm_bot_command" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/ssm?ref=tf-modules"

  parameter_name = var.bot_command_name
  parameter_type = "String"

  # Module tags
  label_id = module.tags.label_id
  tags     = module.tags.tags
}

module "ssm_api_gw_key" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/ssm?ref=tf-modules"

  parameter_name = "api_gateway_key"
  parameter_type = "String"
  value          = null

  # Module tags
  label_id = module.tags.label_id
  tags     = module.tags.tags
}

########################
#     API Gateway      #
########################
module "api_gateway" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/api-gateway?ref=tf-modules"

  # lambda integration
  lambda_function_name = module.lambda.lambda_function_name
  lambda_invoke_arn    = module.lambda.lambda_function_invoke_arn

  # Module tags
  label_id = module.tags.label_id
  tags     = module.tags.tags
}

########################
#    Lambda Function   #
########################
module "lambda" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/lambda?ref=tf-modules"

  # aws region
  aws_region = var.aws_region

  # Lambda Config
  lambda_runtime = var.lambda_runtime
  lambda_timeout = var.lambda_timeout

  # SSM
  bot_command_name     = module.ssm_bot_command.ssm_parameter_name
  terraform_token_name = var.terraform_token_name

  # Lambda Environment vars
  subnet_id                      = module.vpc.subnet_id
  security_group_id              = module.security_group.security_group_id
  mc_server_ip                   = module.eip.eip_public_ip
  mc_port                        = var.mc_port
  ssm_git_private_key_name       = var.ssm_git_private_key_name
  ssm_ec2_private_key_name       = module.ssm_mc_server_private_key.ssm_parameter_name
  ec2_instance_id                = module.minecraft_server.ec2_instance_id
  git_branch                     = var.git_branch
  s3_minecraft_world_bucket_url  = module.s3_mc_world.s3_bucket_uri
  s3_minecraft_assets_bucket_url = module.s3_mc_server_assets.s3_bucket_uri
  api_gateway_url                = module.api_gateway.api_gateway_url
  ssm_api_key_name               = module.ssm_api_gw_key.ssm_parameter_name

  # Module tags
  label_id = module.tags.label_id
  tags     = module.tags.tags
}

########################
#       S3 Bucket      #
########################
module "s3_mc_world" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/s3?ref=tf-modules"

  # S3 Bucket 
  bucket_name = "world-data"

  # Module tags
  label_id = module.tags.label_id
  tags     = module.tags.tags
}

module "s3_mc_server_assets" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/s3?ref=tf-modules"

  # S3 Bucket 
  bucket_name           = "mc-server-assets"
  version_config_status = "Enabled"

  # Module tags
  label_id = module.tags.label_id
  tags     = module.tags.tags
}

################################
#    Minecraft Server EC2      #
################################
module "minecraft_server" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/ec2-instance?ref=tf-modules"

  # EC2 Instance Config
  ami                     = var.ami
  ami_owners              = var.ami_owners
  ami_root_device_type    = var.ami_root_device_type
  ami_virtualization_type = var.ami_virtualization_type
  instance_keypair        = module.ec2_key_pair.key_pair_name
  architecture            = var.architecture
  instance_type           = var.instance_type

  # Security group
  security_group_id = module.security_group.security_group_id


  # IAM
  ssm_git_private_key_name = var.ssm_git_private_key_name
  mc_s3_bucket_arn         = module.s3_mc_world.s3_bucket_arn

  # Public IP
  public_ip = module.eip.eip_public_ip

  # VPC
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.subnet_id

  # Module tags
  tags = module.tags.tags
}


