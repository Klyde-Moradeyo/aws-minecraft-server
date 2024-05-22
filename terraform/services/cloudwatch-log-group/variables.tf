########################
#    Resource Naming   #
########################
variable "name" {
  description = "The base name of the resources"
  type        = string
}

########################
#   Cloud Watch logs   #
########################
variable "retention_in_days" {
  description = "Retention period in days"
  type        = number
  default     = 90
}

variable "resource_policies" {
  description = "A list of CloudWatch log resource policies"
  type = list(object({
    name     = string
    document = string
  }))
  default = []
}

variable "subscription_filters" {
  description = "A list of CloudWatch subscription filters"
  type = list(object({
    name            = string
    pattern         = string
    destination_arn = string
    role_arn        = string
    distribution    = string
  }))
  default = []
}

########################
#         Tags         #
########################
variable "tags" {
  description = "Tags from labels module"
  type        = map(string)
}
