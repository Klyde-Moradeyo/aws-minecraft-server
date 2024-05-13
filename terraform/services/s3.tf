########################
#       S3 Bucket      #
########################
module "s3_mc_world" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/s3/aws"
  version = "0.0.2"

  name               = "${var.name}-world-data"
  versioning_enabled = true

  # logging
  enable_logging        = true
  logging_target_bucket = module.s3_access_logs.bucket_name

  tags = module.tags.tags
}

module "s3_mc_server_assets" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/s3/aws"
  version = "0.0.1"

  name               = "${var.name}-assets"
  versioning_enabled = true

  # logging
  enable_logging        = true
  logging_target_bucket = module.s3_access_logs.bucket_name

  tags = module.tags.tags
}

module "s3_access_logs" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/s3/aws"
  version = "0.0.1"

  name               = "${var.name}-s3-access-logs"
  versioning_enabled = false

  tags = module.tags.tags
}