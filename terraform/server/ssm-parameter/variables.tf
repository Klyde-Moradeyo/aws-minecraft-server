########################
#    Resource Naming   #
########################
variable "name" {
  description = "The base name of the resources"
  type        = string
}

########################
#    SSM Parameter     #
########################
variable "parameters" {
  type = list(object({
    name        : string
    description : string
    type        : string
    value       : string
    key_id      : string
    overwrite   : bool
    ignore_changes : bool
  }))
  description = "A list of SSM parameter configurations."
}

########################
#         Tags         #
########################
variable "tags" {
  description = "Tags from labels module"
  type        = map(string)
}
