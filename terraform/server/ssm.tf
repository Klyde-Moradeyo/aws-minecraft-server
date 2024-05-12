########################
#    Systems Manager   #
########################
module "ssm_mc_server_private_key" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/ssm?ref=tf-modules"

  parameter_name = "mc_server/private_key"
  parameter_type = "SecureString"
  value          = module.ec2_key_pair.private_key_pem

  # Module tags
  tags = module.tags.tags
}
