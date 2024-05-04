module "vpc" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/vpc/aws"
  version = "0.0.1"

  name = var.name
  vpc_cidr = ""
  tags = 
}

module "internet-gateway" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/internet-gateway/aws"
  version = "0.0.1"

  name = ""
  tags = 
  vpc_id = ""
}

module "subnet" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/subnet/aws"
  version = "0.0.1"

  name = ""
  subnets = 
  tags = 
  vpc_id = ""
}

module "route-table" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/route-table/aws"
  version = "0.0.1"

  name = ""
  tags = 
  vpc_id = ""
}