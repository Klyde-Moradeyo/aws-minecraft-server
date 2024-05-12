########################
#        VPC           #
########################
module "vpc" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/vpc/aws"
  version = "0.0.1"

  name                 = var.name
  vpc_cidr             = var.vpc_cidr
  enable_dns_hostnames = true
  tags                 = module.tags.tags
}

########################
#        Subnets       #
########################
locals {
  public_subnets = { for i, az in data.aws_availability_zones.available.names : az => element(var.public_subnet_cidrs, i) }
}

module "public_subnet" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/subnet/aws"
  version = "0.0.1"

  name                    = "${var.name}-public"
  vpc_id                  = module.vpc.vpc_id
  subnets                 = {
    keys(local.public_subnets)[0] = local.public_subnets[keys(local.public_subnets)[0]]
  }
  map_public_ip_on_launch = false

  tags = module.tags.tags
}

########################
#   Internet Gateway   #
########################
module "internet_gateway" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/internet-gateway/aws"
  version = "0.0.1"

  name   = var.name
  vpc_id = module.vpc.vpc_id

  tags = module.tags.tags
}

########################
#     Route Table      #
########################
module "public_route_table" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/route-table/aws"
  version = "0.0.1"

  name   = "${var.name}-public"
  vpc_id = module.vpc.vpc_id
  routes = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = module.internet_gateway.internet_gateway_id
    }
  ]
  subnets = module.public_subnet.subnet_ids

  tags = module.tags.tags
}

########################
#  EC2 Security Group  #
########################
module "security_group" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/security-group/aws"
  version = "0.0.1"

  name   = var.name
  vpc_id = module.vpc.vpc_id

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
    }
  ]

  tags = module.tags.tags
}
