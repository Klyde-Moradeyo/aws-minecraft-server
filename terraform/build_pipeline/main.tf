data "terraform_remote_state" "my_state" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    key    = var.remote_state_key
    region = var.remote_state_aws_region
  }
}

module "iam-user" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-user/aws"
  version = "0.0.1"

  name = var.name
  path = "/CI-CD/${var.project}/"

  policy_arns = {}

  tags = module.tags.tags
}

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
    git_repo = "https://github.com/Klyde-Moradeyo/aws-minecraft-server"
  }
}