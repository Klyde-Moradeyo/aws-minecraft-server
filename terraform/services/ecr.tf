########################
#         ECR          #
########################
module "ecr_mc_world_archive" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/ecr/aws"
  version = "0.0.2"

  name                 = "${var.name}-world-archive"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true

  lifecycle_policy_rules = [
    {
      rulePriority = 1
      description  = "Expire untagged images"
      selection_tag = {
        tagStatus   = "untagged"
        countType   = "imageCountMoreThan"
        countNumber = 1
      }
      action_type = "expire"
    }
  ]

  tags = module.tags.tags
}