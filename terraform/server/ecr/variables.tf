########################
#    Resource Naming   #
########################
variable "name" {
  description = "The name of the resources"
  type        = string
}

########################
#         ECR          #
########################
variable "image_tag_mutability" {
  description = "Image tag mutability settings (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository (true or false)"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type to use for the repository (AES256 or KMS)"
  type        = string
  default     = "AES256"
}

variable "kms_key_id" {
  description = "The ARN of the KMS key to use for encryption. Required if encryption_type is KMS"
  type        = string
  default     = ""
}

variable "lifecycle_policy_rules" {
  description = "A list of maps defining lifecycle policy rules"
  type = list(object({
    rulePriority   = number
    description    = string
    selection_tag  = object({
      tagStatus   = string
      countType   = string
      countNumber = number
    })
    action_type    = string
  }))
  default = []
}

########################
#         Tags         #
########################
variable "tags" {
  description = "Tags from tags module"
  type        = map(string)
}
