########################
#       tags           #
########################
module "tags" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/tags/helpers"
  version = "0.0.1"

  client      = var.client
  environment = var.environment
  namespace   = var.namespace
  owner       = var.owner
  project     = var.project
  additional_tags = {
    git_branch   = var.git_branch
    git_repo_url = "https://github.com/Klyde-Moradeyo/aws-minecraft-server"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}