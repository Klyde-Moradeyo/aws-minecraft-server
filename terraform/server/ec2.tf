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
      protocol         = "udp"
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

