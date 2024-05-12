########################
#   Resource Naming    #
########################
variable "name" {
  description = "name"
  type        = string
  default     = "minecraft-server-build-pipeline"
}

########################
#     General AWS      #
########################
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "eu-west-1"
}

########################
#        tags          #
########################
variable "project" {
  description = "The name of the project"
  type        = string
  default     = "personal-mincecraft-server"
}

variable "client" {
  description = "The client for the project"
  type        = string
  default     = "Klyde-Moradeyo"
}

variable "owner" {
  description = "The owner of the project"
  type        = string
  default     = "Klyde-Moradeyo"
}

variable "namespace" {
  description = "Logical grouping for resources, such as by service"
  type        = string
  default     = "minecraft"
}

variable "environment" {
  description = "The project environment"
  type        = string
  default     = "prod"
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
  default     = "aws-minecraft-server/feature/migrate-infra-to-terraform-registry/terraform.tfstate"
}

variable "remote_state_aws_region" {
  description = "The AWS region where the S3 bucket for remote state is located"
  type        = string
  default     = "eu-west-2"
}

