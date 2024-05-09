########################
#   Resource Naming    #
########################
module "resource_name_prefix" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/resource-name-prefix/aws"
  version = "0.0.1"

  name = var.name
  tags = var.tags
}

########################
#         ECR          #
########################
resource "aws_ecr_repository" "ecr" {
  name                 = "${module.resource_name_prefix.resource_name}-ecr"
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.kms_key_id
  }

  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_policy" {
  count      = length(var.lifecycle_policy_rules) > 0 ? 1 : 0
  repository = aws_ecr_repository.ecr.name

  policy = jsonencode({
    rules = [for rule in var.lifecycle_policy_rules : {
      rulePriority = rule.rulePriority
      description  = rule.description
      selection = {
        tagStatus     = rule.selection_tag.tagStatus
        countType     = rule.selection_tag.countType
        countNumber   = rule.selection_tag.countNumber
      }
      action = {
        type = rule.action_type
      }
    }]
  })
}
