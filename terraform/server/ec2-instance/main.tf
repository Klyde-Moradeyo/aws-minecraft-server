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
#     EC2 Instance     #
########################
resource "aws_instance" "ec2_instance" {
  ami                                  = var.ami
  instance_type                        = var.instance_type
  key_name                             = var.key_name
  user_data                            = var.user_data
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

  # Network
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  # Iam role
  iam_instance_profile = length(var.iam_role) > 0 ? aws_iam_instance_profile.minecraft_server_instance_profile[0].name : ""

  dynamic "instance_market_options" {
    for_each = var.spot_instance ? [1] : []
    content {
      market_type = "spot"
      spot_options {
        max_price = var.spot_price != "" ? var.spot_price : null
      }
    }
  }

  tags = merge(
    var.tags,
    { "Name" = "${module.resource_name_prefix.resource_name}-ec2" }
  )
}

resource "aws_iam_instance_profile" "minecraft_server_instance_profile" {
  count = length(var.iam_role) > 0 ? 1 : 0
  name  = "${module.resource_name_prefix.resource_name}-ec2-instance-profile"
  role  = var.iam_role
  tags = merge(
    var.tags,
    { "Name" = "${module.resource_name_prefix.resource_name}-ec2-instance-profile" }
  )
}

resource "aws_volume_attachment" "ebs_att" {
  for_each = { for att in var.volume_attachment : att.device_name => att }

  device_name = each.value.device_name
  volume_id   = each.value.volume_id
  instance_id = aws_instance.ec2_instance.id
}

module "eip" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/eip/aws"
  version = "0.0.1"

  count = var.associate_public_ip_address ? 1 : 0

  name        = var.name
  instance_id = aws_instance.ec2_instance.id

  tags = var.tags
}