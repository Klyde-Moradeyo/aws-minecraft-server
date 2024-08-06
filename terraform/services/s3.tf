########################
#       S3 Bucket      #
########################
module "s3_mc_world" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/s3/aws"
  version = "0.0.3"

  name = "${var.name}-world-data"

  # S3 Bucket settings
  force_destroy      = var.environment == "prod" ? false : true
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
  logging_target_bucket = module.s3_access_logs.name

  tags = module.tags.tags
}

module "s3_mc_server_assets" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/s3/aws"
  version = "0.0.3"

  name = "${var.name}-assets"

  # S3 Bucket settings
  force_destroy      = var.environment == "prod" ? false : true
  versioning_enabled = true
  lifecycle_rules = [
    {
      id                      = "expire-older-versions"
      status                  = "Enabled"
      expiration_days         = null
      noncurrent_version_days = 7
    },
    {
      id                      = "expire-mc-archive-older-versions"
      status                  = "Enabled"
      expiration_days         = null
      noncurrent_version_days = 35
      filter = {
        prefix = "*/world_bck_up/*.bundle"
        tags   = []
      }
    }
  ]

  # Logging configuration
  enable_logging        = true
  logging_target_bucket = module.s3_access_logs.name

  tags = module.tags.tags
}

module "s3_access_logs" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/s3/aws"
  version = "0.0.3"

  # Naming and tagging
  name = "${var.name}-s3-access-logs"

  # S3 Bucket settings
  force_destroy      = var.environment == "prod" ? false : true
  versioning_enabled = true
  lifecycle_rules = [
    {
      id                      = "clean-up-log-files"
      status                  = "Enabled"
      expiration_days         = 30
      noncurrent_version_days = null
    }
  ]

  tags = module.tags.tags
}

resource "aws_s3_bucket_policy" "logging_bucket_policy" {
  bucket = module.s3_access_logs.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:PutObject"
        Effect   = "Allow"
        Resource = "${module.s3_access_logs.arn}/*"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
      }
    ]
  })
}
