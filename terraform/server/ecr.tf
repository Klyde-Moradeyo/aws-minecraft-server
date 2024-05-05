########################
#         ECR          #
########################
module "ecr_mc_world_archive" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/ecr/aws"
  version = "0.0.1"

  name = "${var.name}-world-archive"
  image_tag_mutability = "MUTABLE"
  scan_on_push = true
  lifecycle_policy_rules = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images"
        selection = {
          tagStatus   = "untagged"
          countType   = "imageCountMoreThan"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = module.tags.tags
}

resource "aws_ecr_lifecycle_policy" "delete_untagged_images" {
  repository = module.mc_world_archive_ecr_registry.repository_name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images"
        selection = {
          tagStatus   = "untagged"
          countType   = "imageCountMoreThan"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}