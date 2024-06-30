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
  public_subnets                       = { for i, az in data.aws_availability_zones.available.names : az => element(var.public_subnet_cidrs, i) }
  ecs_mc_archiver_private_subnet_cidrs = { for i, az in data.aws_availability_zones.available.names : az => element(var.ecs_mc_archiver_private_subnet_cidrs, i) }
}

module "public_subnet" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/subnet/aws"
  version = "0.0.1"

  name   = "${var.name}-public"
  vpc_id = module.vpc.vpc_id
  subnets = {
    keys(local.public_subnets)[0] = local.public_subnets[keys(local.public_subnets)[0]]
  }
  map_public_ip_on_launch = false

  tags = module.tags.tags
}

# module "ecs_mc_archiver_private_subnet_cidrs" {
#   source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/subnet/aws"
#   version = "0.0.1"

#   name   = "${var.name}-world-archive-ecs"
#   vpc_id = module.vpc.vpc_id
#   subnets = {
#     keys(local.ecs_mc_archiver_private_subnet_cidrs)[0] = local.ecs_mc_archiver_private_subnet_cidrs[keys(local.ecs_mc_archiver_private_subnet_cidrs)[0]]
#   }
#   map_public_ip_on_launch = false

#   tags = module.tags.tags
# }

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