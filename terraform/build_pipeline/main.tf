locals {
  iam_policy_create             = "${var.name}-create"
  iam_policy_read               = "${var.name}-read"
  iam_policy_update             = "${var.name}-update"
  iam_policy_delete             = "${var.name}-delete"
  iam_policy_tf_s3_state_access = "${var.name}-tf-s3-state-access"
  iam_path                      = "/ci-cd/${data.terraform_remote_state.my_state.outputs.tags["Project"]}/"
}

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
  path = local.iam_path

  policy_arns = {
    "${local.iam_policy_create}"             = module.iam_policy_create.policy_arn
    "${local.iam_policy_read}"               = module.iam_policy_read.policy_arn
    "${local.iam_policy_delete}"             = module.iam_policy_delete.policy_arn
    "${local.iam_policy_update}"             = module.iam_policy_update.policy_arn
    "${local.iam_policy_tf_s3_state_access}" = module.iam_policy_tf_s3_state_access.policy_arn
  }

  tags = data.terraform_remote_state.my_state.outputs.tags
}