########################
#       tags         #
########################
module "tags" {
  source = "../modules/tags"

  environment = "prod-2"
}

########################
#        VPC           #
########################
module "vpc" {
  source       = "../modules/vpc"
  vpc_cidr     = "10.0.0.0/16"
  subnet_cidrs = "10.0.2.0/24"
  tags = module.tags.tags
}

module "security_group" {
  source = "../modules/security-group"

  vpc_id         = module.vpc.vpc_id
  tags = module.tags.tags

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.allowed_cidrs]
      ipv6_cidr_blocks = []
      description = "SSH access from anywhere"
    },
    {
      from_port   = var.mc_port
      to_port     = var.mc_port
      protocol    = "tcp"
      cidr_blocks = [var.allowed_cidrs]
      ipv6_cidr_blocks = []
      description = "Minecraft Server Port"
    },
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
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      description = "Allow all outbound traffic"
    },
  ]
}

########################
#         EIP          #
########################
module "eip" {
  source = "../modules/eip"

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
  source = "../modules/ssm"

  parameter_name = "mc_server/private_key"
  parameter_type = "SecureString"
  value          = module.ec2_key_pair.private_key_pem

  # Module tags
  label_id   = module.tags.label_id
  tags = module.tags.tags
}

module "ssm_bot_command" {
  source = "../modules/ssm"

  parameter_name = var.bot_command_name
  parameter_type = "String"

  # Module tags
  label_id   = module.tags.label_id
  tags = module.tags.tags
}

########################
#     API Gateway      #
########################
module "api_gateway" {
  source = "../modules/api_gateway"

  # lambda integration
  lambda_function_name = module.lambda.lambda_function_name
  lambda_invoke_arn    = module.lambda.lambda_function_invoke_arn

  # Module tags
  label_id   = module.tags.label_id
  tags = module.tags.tags
}

########################
#    Lambda Function   #
########################
module "lambda" {
  source = "../modules/lambda"

  # Lambda Config
  lambda_runtime = var.lambda_runtime
  lambda_timeout = var.lambda_timeout

  # SSM
  bot_command_name     = module.ssm_bot_command.ssm_parameter_name
  terraform_token_name = var.terraform_token_name

  # Lambda Environment vars
  subnet_id            = module.vpc.subnet_id
  security_group_id    = module.security_group.security_group_id
  mc_server_ip         = module.eip.eip_public_ip
  mc_port              = var.mc_port
  git_private_key_name = var.git_private_key_name
  ec2_private_key_name = module.ssm_mc_server_private_key.ssm_parameter_name
  ec2_instance_id      = module.minecraft_server.ec2_instance_id

  # Module tags
  label_id   = module.tags.label_id
  tags = module.tags.tags
}

########################
#       S3 Bucket      #
########################
module "s3_mc_world" {
  source = "../modules/s3"

  # S3 Bucket 
  bucket_name = "world-data"

  # Module tags
  label_id   = module.tags.label_id
  tags = module.tags.tags
}

module "s3_mc_server_assets" {
  source = "../modules/s3"

  # S3 Bucket 
  bucket_name           = "mc-server-assets"
  version_config_status = "Enabled"

  # Module tags
  label_id   = module.tags.label_id
  tags = module.tags.tags
}

################################
#    Minecraft Server EC2      #
################################
module "minecraft_server" {
  source = "../modules/ec2-instance"

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
  git_private_key_name = var.git_private_key_name
  mc_s3_bucket_arn     = module.s3_mc_world.s3_bucket_arn

  # Public IP
  public_ip = module.eip.eip_public_ip

  # VPC
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.subnet_id

  # Module tags
  tags = module.tags.tags
}


