##########################
#     Naming Config      #
##########################
module "resource_name_prefix" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/resource-name-prefix/aws"
  version = "0.0.1"

  name = var.name
  tags = var.tags
}

########################
#    SSM Parameter     #
########################
resource "aws_ssm_parameter" "param" {
  for_each    = { for idx, param in var.parameters : idx => param }

  name        = each.value.name
  description = each.value.description
  type        = each.value.type
  value       = each.value.value
  key_id      = each.value.type == "SecureString" ? each.value.key_id : null

  tags        = var.tags
}