########################
#       S3 Bucket      #
########################
module "s3_mc_world" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/s3/aws"
  version = "0.0.3"

  name               = "${var.name}-world-data"

  # S3 Bucket settings
  force_destroy      = false
  versioning_enabled = true
  lifecycle_rules = [
    {
      id                      = "expire-older-versions"
      status                  = "Enabled"
      expiration_days         = null
      noncurrent_version_days = 7
    }
  ]

  # Logging configuration
  enable_logging        = true
  logging_target_bucket = module.s3_access_logs.arn

  tags = module.tags.tags
}

module "s3_mc_server_assets" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/s3/aws"
  version = "0.0.3"

  name               = "${var.name}-assets"

  # S3 Bucket settings
  force_destroy      = false
  versioning_enabled = true
  lifecycle_rules = [
    {
      id                      = "expire-older-versions"
      status                  = "Enabled"
      expiration_days         = null
      noncurrent_version_days = 35
    }
  ]

  # Logging configuration
  enable_logging        = true
  logging_target_bucket = module.s3_access_logs.arn

  tags = module.tags.tags
}

module "s3_access_logs" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/s3/aws"
  version = "0.0.3"

  # Naming and tagging
  name = "${var.name}-s3-access-logs"

  # S3 Bucket settings
  force_destroy      = true
  versioning_enabled = true
  lifecycle_rules = [
    {
      id                      = "clean-up-log-files"
      status                  = "Enabled"
      expiration_days         = 90
      noncurrent_version_days = null
    }
  ]

  tags = module.tags.tags
}