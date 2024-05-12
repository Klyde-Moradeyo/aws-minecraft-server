########################
#    Systems Manager   #
########################
module "ssm_mc_server_private_key" {
  source      = "./ssm-parameter"

  name = var.name
  parameters = [
    {
      name        = "ec2_private_key"
      description = "${var.name} EC2 instance private key."
      type        = "SecureString"
      value       = module.ec2_key_pair.private_key_pem
      key_id      = "alias/aws/ssm"
    }
  ]

  tags = module.tags.tags
}
