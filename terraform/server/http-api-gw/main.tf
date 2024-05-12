##########################
#     Naming Config      #
##########################
module "resource_name_prefix" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/resource-name-prefix/aws"
  version = "0.0.1"

  name = var.name
  tags = var.tags
}

##########################
#       HTTP API         #
##########################
locals {
  api_name = "${module.resource_name_prefix.resource_name}-http-api-gw"
}

resource "aws_api_gateway_rest_api" "api" {
  name        = local.api_name
  description = var.description

  endpoint_configuration {
    types = [ var.endpoint_type ]
  }
}
