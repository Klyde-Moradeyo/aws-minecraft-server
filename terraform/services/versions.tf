terraform {
  required_version = "~> 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "terraform-state-s3-pfqdhvmq"
    key     = "aws-minecraft-server/service/feature/migrate-infra-to-terraform-registry/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}