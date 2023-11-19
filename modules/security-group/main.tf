########################
#   Resource Naming    #
########################
module "resource_naming" {
  source = "../resource-naming"
  tags   = var.tags
}

resource "aws_security_group" "this" {
  vpc_id      = var.vpc_id
  name        = "${module.resource_naming.name}-sg"
  description = "Security group for ${module.resource_naming.name}"
  tags        = var.tags

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = ingress.value.cidr_blocks
      ipv6_cidr_blocks = ingress.value.ipv6_cidr_blocks
      description      = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
      description      = egress.value.description
    }
  }
}
