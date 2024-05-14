terraform {
  required_version = "~> 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.25.0"
    }
  }

  backend "s3" {
    bucket  = "terraform-state-s3-pfqdhvmq"
    key     = "aws-minecraft-server/build-pipeline/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
}

provider "aws" {
  region = data.terraform_remote_state.my_state.outputs.aws_region
}