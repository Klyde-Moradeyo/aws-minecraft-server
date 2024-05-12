########################
#    Resource Naming   #
########################
variable "name" {
  description = "The name of the resources"
  type        = string
}

########################
#      HTTP API        #
########################
variable "description" {
  type        = string
  description = "A description of the API Gateway"
}

variable "resources" {
  type = list(object({
    path_part   = string
    http_method = string
    target_url  = string
  }))
  default = []
}

variable "stages" {
  type = list(object({
    name        = string
    description = string
  }))
  default = []
}

variable "endpoint_type" {
  description = "The type of endpoint to use for the API Gateway. Valid options are REGIONAL, EDGE_OPTIMIZED, and PRIVATE."
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = contains(["REGIONAL", "EDGE_OPTIMIZED", "PRIVATE"], var.endpoint_type)
    error_message = "Invalid endpoint type. Valid options are REGIONAL, EDGE_OPTIMIZED, and PRIVATE."
  }
}

variable "log_retention_days" {
  description = "Log Retention period in days"
  type        = number
}

########################
#         Tags         #
########################
variable "tags" {
  description = "Tags to assign"
  type        = map(string)
}