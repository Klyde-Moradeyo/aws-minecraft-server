########################
#       S3 Bucket      #
########################
module "s3_mc_world" {
  source = "./s3"

  name               = "${var.name}-world-data"
  versioning_enabled = true

  # logging
  enable_logging        = true
  logging_target_bucket = module.s3_access_logs.bucket_name

  tags = module.tags.tags
}

module "s3_mc_server_assets" {
  source = "./s3"

  name               = "${var.name}-assets"
  versioning_enabled = true

  # logging
  enable_logging        = true
  logging_target_bucket = module.s3_access_logs.bucket_name

  tags = module.tags.tags
}

module "s3_access_logs" {
  source = "./s3"

  name               = "${var.name}-s3-access-logs"
  versioning_enabled = false

  tags = module.tags.tags
}