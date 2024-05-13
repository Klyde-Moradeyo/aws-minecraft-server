########################
#   Resource Naming    #
########################
variable "name" {
  description = "name"
  type        = string
  default     = "minecraft-server-build-pipeline"
}

########################
#     Remote State     #
########################
variable "remote_state_bucket" {
  description = "The S3 bucket name where the remote state is stored"
  type        = string
  default     = "terraform-state-s3-pfqdhvmq"
}

variable "remote_state_key" {
  description = "The key path at which the remote state is stored in the S3 bucket"
  type        = string
  default     = "aws-minecraft-server/service/migrate-infra-to-terraform-registry/terraform.tfstate"
}

variable "remote_state_aws_region" {
  description = "The AWS region where the S3 bucket for remote state is located"
  type        = string
  default     = "eu-west-2"
}

variable "remote_state_s3_bucket" {
  description = "The AWS region where the S3 bucket for remote state is located"
  type        = string
  default     = "terraform-state-s3-pfqdhvmq"
}

