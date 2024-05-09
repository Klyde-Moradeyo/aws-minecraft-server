########################
#    Resource Naming   #
########################
variable "name" {
  description = "The base name of the resources"
  type        = string
}

########################
#     ECS Cluster      #
########################
variable "capacity_providers" {
  description = "List of capacity providers to associate with the ECS cluster."
  type        = list(string)
  default     = []
}

variable "default_capacity_provider_strategy" {
  description = "List of default capacity provider strategies."
  type = list(object({
    capacity_provider = string
    weight            = number
    base              = number
  }))
  default = []
}

variable "container_insights" {
  description = "Enable container insights monitoring."
  type        = bool
  default     = true
}

########################
#         Tags         #
########################
variable "tags" {
  description = "Tags from labels module"
  type        = map(string)
}
