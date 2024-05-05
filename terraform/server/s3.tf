########################
#       S3 Bucket      #
########################
module "s3_mc_world" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/s3?ref=tf-modules"

  # S3 Bucket 
  bucket_name           = "world-data"
  version_config_status = "Enabled"

  # Module tags
  label_id = module.tags.label_id
  tags     = module.tags.tags
}

module "s3_mc_server_assets" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/s3?ref=tf-modules"

  # S3 Bucket 
  bucket_name           = "mc-server-assets"
  version_config_status = "Enabled"

  # Module tags
  label_id = module.tags.label_id
  tags     = module.tags.tags
}