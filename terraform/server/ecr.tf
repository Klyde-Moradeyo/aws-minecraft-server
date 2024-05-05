########################
#         ECR          #
########################
module "mc_world_archive_ecr_registry" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/ecr?ref=tf-modules"

  repo_name = "world-archive"

  # Module tags
  tags = module.tags.tags
}

module "mc_monitoring_ecr_registry" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/ecr?ref=tf-modules"

  repo_name = "server-monitoring"

  # Module tags
  tags = module.tags.tags
}