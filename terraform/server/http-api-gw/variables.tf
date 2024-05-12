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
  description = "Description of the API Gateway."
}

variable "integrations" {
  type = map(object({
    type           : string
    uri            : string
    payload_version: string
  }))
  description = "Map of integrations keyed by their unique names."
}

variable "routes" {
  type = map(object({
    route_key      : string
    integration_key: string
  }))
  description = "Map of routes keyed by their unique names."
}

variable "stages" {
  type = map(object({
    auto_deploy : bool
    logging     : optional(object({
      enabled        : bool
      format         : string
      retention_days : number
    }))
  }))
  description = "Map containing stage configurations with optional logging."
}

########################
#         Tags         #
########################
variable "tags" {
  description = "Tags to assign"
  type        = map(string)
}