########################
#   Resource Naming    #
########################
module "resource_naming" {
    source = "../resource-naming"
    tags = var.tags
}

########################
#         ECR          #
########################
resource "aws_ecr_repository" "mc_repository" {
  name                 = "${module.resource_naming.name}-ecr-repo"
  image_tag_mutability = "MUTABLE"
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "delete_untagged_images" {
  repository = aws_ecr_repository.mc_repository.name

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
