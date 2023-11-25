########################
#   Resource Naming    #
########################
module "resource_naming" {
  source = "../resource-naming"
  tags   = var.tags
}

########################
#     EC2 Instance     #
########################
// Get latest Ubuntu 22.04AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = var.ami_owners

  filter {
    name   = "name"
    values = var.ami
  }

  filter {
    name   = "root-device-type"
    values = var.ami_root_device_type
  }

  filter {
    name   = "virtualization-type"
    values = var.ami_virtualization_type
  }


  filter {
    name   = "architecture"
    values = var.architecture
  }
}

resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.ubuntu.image_id
  instance_type          = var.instance_type
  key_name               = var.instance_keypair
  iam_instance_profile   = aws_iam_instance_profile.mc.name
  vpc_security_group_ids = [var.security_group_id]
  subnet_id              = var.subnet_id
  monitoring             = true
  tags                   = var.tags
}

resource "null_resource" "delay_before_stop" {
  depends_on = [aws_instance.ec2_instance]
  triggers = { instance_id = aws_instance.ec2_instance.id }

  provisioner "local-exec" {
    command = "sleep 60" # Delay in seconds
  }
}

resource "null_resource" "stop_instance" {
  depends_on = [null_resource.delay_before_stop]
  triggers = { instance_id = aws_instance.ec2_instance.id }

  provisioner "local-exec" {
    command = "aws ec2 stop-instances --instance-ids ${aws_instance.ec2_instance.id}"
  }
}

data "aws_eip" "mc_public_ip" {
  public_ip = var.public_ip
}

resource "aws_eip_association" "mc_public_ip_to_ec2" {
  instance_id   = aws_instance.ec2_instance.id
  allocation_id = data.aws_eip.mc_public_ip.id
}