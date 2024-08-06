########################
#    Resource Naming   #
########################
variable "name" {
  description = "The name of the resources"
  type        = string
}

########################
#         SNS          #
########################
variable "display_name" {
  type        = string
  description = "The display name for the SNS topic"
  default     = ""
}

variable "kms_master_key_id" {
  type        = string
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SNS or a custom CMK"
  default     = ""
}

variable "policy" {
  type        = string
  description = "The fully-formed AWS policy as JSON"
  default     = ""
}

variable "subscriptions" {
  type        = list(map(string))
  description = "A list of subscription definitions"
  default     = []
}

########################
#         Tags         #
########################
variable "tags" {
  description = "Tags from tags module"
  type        = map(string)
}
