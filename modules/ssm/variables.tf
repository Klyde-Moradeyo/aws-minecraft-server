########################
#         Tags         #
########################
variable "label_id" {
  description = "ID from tags module"
  type        = string
}

variable "tags" {
  description = "Tags from tags module"
  type        = map(string)
}

########################
#    Systems Manager   #
########################
variable "parameter_name" {
  description = "SSM parameter name"
  type        = string
}

variable "parameter_type" {
  description = "SSM parameter type"
  type        = string
}

variable "value" {
  description = "Value to set ssm paramter"
  type        = string
  default     = "NOT_SET"
}
