// Fetch AMI
data "aws_ami" "ami" {
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

################################
#              EC2             #
################################
module "minecraft_server" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/ec2-instance/aws"
  version = "0.0.1"

  name          = var.name
  ami           = data.aws_ami.ami.image_id
  instance_type = var.instance_type

  key_name = module.ec2_key_pair.key_pair_name
  iam_role = module.ec2_iam_role.iam_role_name

  # Network
  subnet_id                   = module.public_subnet.subnet_ids[0]
  security_group_ids          = [ module.security_group.security_group_id ]
  associate_public_ip_address = true

  tags = module.tags.tags
}

resource "null_resource" "delay_before_stop" {
  depends_on = [module.minecraft_server]
  triggers   = { instance_id = module.minecraft_server.id }

  provisioner "local-exec" {
    command = "sleep 60" # Delay in seconds
  }
}

resource "null_resource" "stop_instance" {
  depends_on = [null_resource.delay_before_stop]
  triggers   = { instance_id = module.minecraft_server.id }

  provisioner "local-exec" {
    command = "aws ec2 stop-instances --instance-ids ${module.minecraft_server.id}"
  }
}

########################
#     EC2 Key Pair     #
########################
module "ec2_key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "2.0.2"

  key_name           = "dev-test-key"
  create_private_key = true
}

################################
#          EC2 IAM             #
################################
locals {
  ec2_s3_policy_name = "${var.name}-s3-ec2"
  ssm_s3_policy_name = "${var.name}-ssm-ec2"
}

module "ec2_iam_role" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-role/aws"
  version = "0.0.1"

  name        = "${var.name}-ec2"
  path        = "/"
  description = "IAM Role for ${var.name} EC2"
  policy_arns = {
    "${local.ec2_s3_policy_name}" = module.ec2_s3_iam_policy.policy_arn,
    "${local.ssm_s3_policy_name}" = module.ec2_ssm_iam_policy.policy_arn
  }

  trust_policy_hcl = {
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  }

  tags = module.tags.tags
}

################################
#        EC2 Policy            #
################################
module "ec2_s3_iam_policy" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.ec2_s3_policy_name
  description = "IAM Policy for ${var.name} EC2 access to S3 buckets"

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:ListBucket"]
        Resource = [
          module.s3_mc_world.bucket_arn,
          module.s3_mc_server_assets.bucket_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
        ]
        Resource = [
          "${module.s3_mc_world.bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
        ]
        Resource = [
          "${module.s3_mc_server_assets.bucket_arn}/*/assets/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
        ]
        Resource = [
          "${module.s3_mc_server_assets.bucket_arn}/*/logs/*"
        ]
      },
    ]
  }

  tags = module.tags.tags
}

module "ec2_ssm_iam_policy" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.ssm_s3_policy_name
  description = "IAM Policy for ${var.name} EC2 to SSM parameters"

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = [
          "arn:aws:ssm:*:847399026905:parameter/${var.ssm_git_private_key_name}"
        ]
      }
    ]
  }

  tags = module.tags.tags
}