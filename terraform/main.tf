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

########################
#    Security Group    #
########################
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
    },
    {
      from_port        = 9149
      to_port          = 9149
      protocol         = "tcp"
      cidr_blocks      = [var.allowed_cidrs]
      ipv6_cidr_blocks = []
      description      = "cAdvisor Metrics"
    },
    {
      from_port        = 9150
      to_port          = 9150
      protocol         = "tcp"
      cidr_blocks      = [var.allowed_cidrs]
      ipv6_cidr_blocks = []
      description      = "Minecraft Exporter Metrics"
    },
    {
      from_port        = 9100
      to_port          = 9100
      protocol         = "tcp"
      cidr_blocks      = [var.allowed_cidrs]
      ipv6_cidr_blocks = []
      description      = "Node Exporter Metrics"
    },
    {
      from_port        = 9256
      to_port          = 9256
      protocol         = "tcp"
      cidr_blocks      = [var.allowed_cidrs]
      ipv6_cidr_blocks = []
      description      = "Process Exporter Metricst"
    },
    {
      from_port        = 25585
      to_port          = 25585
      protocol         = "tcp"
      cidr_blocks      = [var.allowed_cidrs]
      ipv6_cidr_blocks = []
      description      = "Fabric Minecraft Exporter Metrics"
    },
    {
      from_port        = 24454
      to_port          = 24454
      protocol         = "tcp"
      cidr_blocks      = [var.allowed_cidrs]
      ipv6_cidr_blocks = []
      description      = "Simple Voice Chat Mod"
    }
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
#         ECR          #
########################
module "mc_world_archive_ecs_registry" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/ecr?ref=tf-modules"

  repo_name = "world-archive"

  # Module tags
  tags = module.tags.tags
}

module "mc_monitoring_ecs_registry" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/ecr?ref=tf-modules"

  repo_name = "server-monitoring"

  # Module tags
  tags = module.tags.tags
}

########################
#         ECS          #
########################
module "mc_world_archive_cluster" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/ecs?ref=tf-modules"

  aws_region = var.aws_region

  # Task Resources
  task_cpu_limit    = 256
  task_memory_limit = 1024

  # SSM
  ssm_git_private_key_name = "dark-mango-bot-private-key"

  # S3 
  minecraft_world_s3_bucket  = module.s3_mc_world.s3_bucket_arn
  minecraft_assets_s3_bucket = module.s3_mc_server_assets.s3_bucket_arn

  # Module tags
  tags = module.tags.tags
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

  parameter_name = "request_lambda_api_gw_auth_token"
  parameter_type = "String"
  value          = "null"

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
  lambda_function_name = module.request_lambda.lambda_function_name
  lambda_invoke_arn    = module.request_lambda.lambda_function_invoke_arn

  # Module tags
  label_id = module.tags.label_id
  tags     = module.tags.tags
}

########################
#    DynamoDB Table    #
########################
module "dynamodb_table" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/dynamodb-table?ref=tf-modules"

  table_name = "my-table"
  hash_key   = "task_id"
  attributes = [
    { name = "task_id", type = "S" },
  ]
  read_capacity_units  = 10
  write_capacity_units = 10
  ttl_enabled          = true
  ttl_attribute        = "TTL"
  tags                 = module.tags.tags
}

########################
#    Request Lambda    #
########################
module "request_lambda" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/request-lambda?ref=tf-modules"

  # aws region
  aws_region = var.aws_region

  # Lambda Config
  lambda_runtime          = "python3.10"
  lambda_timeout          = 900
  lambda_memory_size      = 128
  lambda_payload_zip_path = "./request_lambda_latest.zip"

  # IAM
  ec2_instance_arn = module.minecraft_server.ec2_instance_arn
  worker_lambda_arn = module.worker_lambda.lambda_function_arn

  # Lambda Environment vars
  ec2_instance_id     = module.minecraft_server.ec2_instance_id
  mc_server_ip        = module.eip.eip_public_ip
  mc_port             = var.mc_port
  worker_lambda_name  = module.worker_lambda.lambda_function_name
  dynamodb_table_name = module.dynamodb_table.table_name
  git_branch          = var.git_branch
  ssm_api_key_name = module.ssm_api_gw_key.ssm_parameter_name

  # Module tags
  tags = module.tags.tags
}

########################
#     Worker Lambda    #
#########################
module "worker_lambda" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/worker-lambda?ref=tf-modules"

  # aws region
  aws_region = var.aws_region

  # Lambda Config
  lambda_runtime          = "python3.10"
  lambda_timeout          = 900
  lambda_memory_size      = 128
  lambda_payload_zip_path = "./worker_lambda_latest.zip"



  # IAM
  ec2_instance_arn = module.minecraft_server.ec2_instance_arn

  # Lambda Environment vars
  ssm_git_private_key_name       = var.ssm_git_private_key_name
  ssm_ec2_private_key_name       = module.ssm_mc_server_private_key.ssm_parameter_name
  git_branch                     = var.git_branch
  s3_minecraft_world_bucket_url  = module.s3_mc_world.s3_bucket_uri
  s3_minecraft_assets_bucket_url = module.s3_mc_server_assets.s3_bucket_uri
  api_gateway_url                = module.api_gateway.api_gateway_url
  ssm_api_key_name = module.ssm_api_gw_key.ssm_parameter_name

  # Module tags
  tags = module.tags.tags
}

########################
#       S3 Bucket      #
########################
module "s3_mc_world" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/s3?ref=tf-modules"

  # S3 Bucket 
  bucket_name           = "world-data"
  version_config_status = "Enabled"

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
  s3_mc_world_uri          = module.s3_mc_world.s3_bucket_arn
  s3_mc_assets_uri         = module.s3_mc_server_assets.s3_bucket_arn

  # Public IP
  public_ip = module.eip.eip_public_ip

  # VPC
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.subnet_id

  # Module tags
  tags = module.tags.tags
}


