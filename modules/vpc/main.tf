########################
#   Resource Naming    #
########################
module "resource_naming" {
    source = "../resource-naming"
    tags = var.tags
}

data "aws_availability_zones" "available" {
  state = "available"
}

########################
#          VPC         #
########################
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  tags = merge(var.tags, {
    "Name" = "${module.resource_naming.name}-vpc"
  })
}

########################
#    Internet Gateway  #
########################
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = merge(var.tags, {
    "Name" = "${module.resource_naming.name}-igw"
  })
}

########################
#        Subnets       #
########################
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.subnet_cidrs
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    "Name" = "${module.resource_naming.name}-subnet"
  })
}

# Update local values
locals {
  vpc_id    = aws_vpc.my_vpc.id
  subnet_id = aws_subnet.my_subnet.id
  igw_id    = aws_internet_gateway.my_igw.id
}
