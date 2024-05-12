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
  path = "/CI-CD/${data.terraform_remote_state.my_state.outputs.tags["Project"]}/"

  policy_arns = {
    "${var.name}" = module.iam_policy.policy_arn
  }

  tags = data.terraform_remote_state.my_state.outputs.tags
}