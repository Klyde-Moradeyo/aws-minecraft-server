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
variable "task_name" {
  type        = string
  description = "The name of the ECS task."
}

variable "docker_image" {
  type        = string
  description = "The Docker image to use in the task."
}

variable "cpu" {
  type        = string
  description = "The amount of CPU to allocate for the task."
}

variable "memory" {
  type        = string
  description = "The amount of memory to allocate for the task."
}

variable "container_essential" {
  type        = bool
  description = "Determines if the container is marked as essential. If the essential container fails, all other containers in the task are stopped."
  default     = true
}

variable "environment_variables" {
  type        = list(map(string))
  description = "List of environment variables for the container."
  default     = []
}

variable "secrets" {
  type        = list(map(string))
  description = "List of secrets for the container."
  default     = []
}

variable "port_mappings" {
  type        = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
  }))
  description = "List of port mappings for the container."
  default     = []
}

variable "cluster_arn" {
  type        = string
  description = "The ARN of the ECS cluster where services using this task definition will be deployed."
}

variable "autoscaling_policies" {
  type = list(object({
    name               = string
    policy_type        = string
    target_value       = number
    metric_type        = string
    scale_in_cooldown  = number
    scale_out_cooldown = number
    disable_scale_in   = bool
  }))
  description = "List of autoscaling policies for the ECS service."
  default     = []
}

variable "max_capacity" {
  type        = number
  description = "Maximum number of tasks to scale out to."
  default     = 10
}

variable "min_capacity" {
  type        = number
  description = "Minimum number of tasks to maintain."
  default     = 1
}

variable "subnets" {
  type        = list(string)
  description = "List of subnet IDs for the ECS service deployment."
}

variable "security_groups" {
  type        = list(string)
  description = "List of security group IDs to associate with the ECS task or service."
}

variable "use_spot_instances" {
  type        = bool
  description = "Whether to use Fargate Spot instances."
  default     = false
}

variable "fargate_spot_weight" {
  type        = number
  description = "The relative percentage of Spot instances."
  default     = 0
}

variable "fargate_weight" {
  type        = number
  description = "The relative percentage of standard Fargate instances."
  default     = 100
}


##########################
#      CloudWatch        #
##########################
variable "log_retention_in_days" {
  type        = number
  description = "The number of days to retain log events in CloudWatch"
}

########################
#         Tags         #
########################
variable "tags" {
  description = "Tags from labels module"
  type        = map(string)
}
