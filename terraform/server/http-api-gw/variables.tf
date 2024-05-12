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

variable "stages" {
  type = map(object({
    auto_deploy : bool
    logging     : optional(object({
      enabled        : bool
      format         : string
      retention_days : number
    }))
    integrations : map(object({
      type           : string
      uri            : string
      payload_version: string
    }))
    routes : map(object({
      route_key      : string
      integration_key: string
    }))
  }))
  description = "Map containing stage configurations with optional logging, integrations, and routes."
}

########################
#         Tags         #
########################
variable "tags" {
  description = "Tags to assign"
  type        = map(string)
}