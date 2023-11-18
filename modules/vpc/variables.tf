########################
#        VPC           #
########################
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type = string
}

variable "subnet_cidrs" {
  description = "List of CIDR blocks for the subnets"
  type = string
}

########################
#         Tags         #
########################
variable "tags" {
  description = "Tags from tags module"
  type        = map(string)
}