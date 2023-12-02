variable "table_name" {
  description = "The name of the DynamoDB table"
  type        = string
}

variable "billing_mode" {
  description = "Controls how you are charged for read and write throughput"
  type        = string
  default     = "PROVISIONED"
}

variable "hash_key" {
  description = "The attribute to use as the hash (partition) key"
  type        = string
}

variable "range_key" {
  description = "The attribute to use as the range (sort) key"
  type        = string
  default     = null
}

variable "attributes" {
  description = "Additional attributes for the table"
  type        = list(map(string))
  default     = []
}

variable "read_capacity_units" {
  description = "The number of read units for this table"
  type        = number
  default     = 5
}

variable "write_capacity_units" {
  description = "The number of write units for this table"
  type        = number
  default     = 5
}

variable "ttl_attribute" {
  description = "The name of the table attribute to store the TTL timestamp"
  type        = string
  default     = ""
}

variable "ttl_enabled" {
  description = "Indicates whether TTL is to be enabled (true) or disabled (false)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
}
