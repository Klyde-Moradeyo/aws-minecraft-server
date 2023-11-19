########################
#   Resource Naming    #
########################
module "resource_naming" {
  source = "../resource-naming"
  tags   = var.tags
}

########################
#          SSM         #
########################
resource "aws_ssm_parameter" "mc_server_private_key" {
  name  = "/${module.resource_naming.name}/${var.parameter_name}"
  type  = var.parameter_type
  value = var.value != "NOT_SET" ? var.value : "null"
  # key_id = "alias/aws/ssm" # Default key for Parameter Store
  tags = var.tags
}