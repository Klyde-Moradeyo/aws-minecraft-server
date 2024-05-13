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
  "${local.iam_policy_create}" = "${var.name}-create"
  "${local.iam_policy_read}" = "${var.name}-read"
  "${local.iam_policy_update}" = "${var.name}-update"
  "${local.iam_policy_delete}" = "${var.name}-delete"
  }

  tags = data.terraform_remote_state.my_state.outputs.tags
}