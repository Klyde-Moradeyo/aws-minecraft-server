########################
#    Resource Naming   #
########################
variable "name" {
  description = "The base name of the resources"
  type        = string
}

########################
#         EC2          #
########################
variable "instance_type" {
  description = "The instance type of the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "ami" {
  description = "The ID of the AMI to use for the instance"
  type        = string
}

variable "key_name" {
  description = "The key name of the Key Pair to use for the instance"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch in"
  type        = string
}

variable "security_group_ids" {
  description = "A list of security group IDs to associate with"
  type        = list(string)
  default     = []
}

variable "iam_role" {
  description = "The IAM role to attach to the instance"
  type        = string
  default     = ""
}

variable "user_data" {
  description = "User data to initialize the instance"
  type        = string
  default     = ""
}

variable "volume_attachment" {
  description = "Information for attaching additional EBS volumes"
  type = list(object({
    device_name = string
    volume_id   = string
  }))
  default = []
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance"
  type        = string
  default     = "stop" # Or use "terminate" as needed
}

variable "spot_instance" {
  description = "Whether to request a spot instance"
  type        = bool
  default     = false
}

variable "spot_price" {
  description = "The maximum price to request for the spot instance"
  type        = string
  default     = ""
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with the instance"
  type        = bool
  default     = false
}

########################
#         Tags         #
########################
variable "tags" {
  description = "Tags from labels module"
  type        = map(string)
}
