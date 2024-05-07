########################
#         ECR          #
########################
module "ecr_mc_world_archive" {
  source  = "./ecr"

  name                 = "${var.name}-world-archive"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true

  lifecycle_policy_rules = [
    {
      rulePriority   = 1
      description    = "Expire untagged images"
      selection_tag  = {
        tagStatus   = "untagged"
        countType   = "imageCountMoreThan"
        countNumber = 1
      }
      action_type    = "expire"
    }
  ]

  tags = module.tags.tags
}