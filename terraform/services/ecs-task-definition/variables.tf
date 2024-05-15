########################
#    Resource Naming   #
########################
variable "name" {
  description = "The base name of the resources"
  type        = string
}

#############################
#    ECS Task Definition    #
#############################
variable "family" {
  description = "The family of the ECS task definition"
  type        = string
}

variable "task_role_arn" {
  description = "The ARN of the IAM role that grants the ECS task the permissions it needs"
  type        = string
  default     = null
}

variable "execution_role_arn" {
  description = "The ARN of the execution role that the Amazon ECS container agent and Fargate use"
  type        = string
  default     = null
}

variable "network_mode" {
  description = "The Docker networking mode to use for the containers in the task [Fargate and EC2]"
  type        = string
  default     = "awsvpc"
}

variable "requires_compatibilities" {
  description = "A set of launch types required by the task definition [Fargate and/or EC2]"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "cpu" {
  description = "The number of CPU units used by the task. Required for Fargate launch type [Fargate]"
  type        = string
  default     = null
}

variable "memory" {
  description = "The amount (in MiB) of memory used by the task. Required for Fargate launch type [Fargate]"
  type        = string
  default     = null
}

variable "container_definitions" {
  description = "A list of container definitions as specified in the ECS task definition [Fargate and EC2]"
  type = list(object({
    name               = string
    image              = string
    cpu                = number
    memory             = number
    memory_reservation = number
    essential          = bool
    port_mappings = list(object({
      container_port = number
      host_port      = number
      protocol       = string
    }))
    environment = list(object({
      name  = string
      value = string
    }))
    log_configuration = object({
      log_driver = string
      options    = map(string)
    })
    mount_points = list(object({
      source_volume  = string
      container_path = string
      read_only      = bool
    }))
  }))
}

variable "placement_constraints" {
  description = "A list of placement constraints [EC2 only]"
  type = list(object({
    type       = string
    expression = string
  }))
  default = []
}

variable "volumes" {
  description = "A list of volume definitions [EC2 only]"
  type = list(object({
    name      = string
    host_path = string
  }))
  default = []
}

variable "inference_accelerators" {
  description = "A list of inference accelerators [EC2 only]"
  type = list(object({
    device_name = string
    device_type = string
  }))
  default = []
}

variable "ipc_mode" {
  description = "IPC resource namespace to use for the containers in the task [EC2 only]"
  type        = string
  default     = null
}

variable "pid_mode" {
  description = "PID namespace to use for the containers in the task [EC2 only]"
  type        = string
  default     = null
}

variable "proxy_configuration" {
  description = "Configuration details for the App Mesh proxy [EC2 only]"
  type = object({
    type           = string
    container_name = string
    properties     = map(string)
  })
  default = null
}

########################
#         Tags         #
########################
variable "tags" {
  description = "Tags from labels module"
  type        = map(string)
}
