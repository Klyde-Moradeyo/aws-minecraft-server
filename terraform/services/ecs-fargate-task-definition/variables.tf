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
variable "containers" {
  type = list(object({
    name                  = string
    image                 = string
    cpu                   = number
    memory                = number
    essential             = optional(bool, true)
    environment_variables = optional(list(map(string)), [])
    secrets               = optional(list(map(string)), [])
    port_mappings = optional(list(object({
      containerPort = number
      hostPort      = number
      protocol      = string
    })), [])
  }))
  description = "List of containers to be used in the task."
}

variable "cpu" {
  type        = string
  description = "The amount of CPU to allocate for the task."
}

variable "memory" {
  type        = string
  description = "The amount of memory to allocate for the task."
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
  description = "(ECS Service Only) List of autoscaling policies for the ECS service."
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

variable "network_config" {
  description = "(ECS Service Only) Network configuration required to deploy the ECS service. Set to null if no service is to be deployed."
  type = object({
    subnets          = list(string)
    security_groups  = list(string)
    assign_public_ip = bool
  })
  default = null
}

##########################
#      IAM Policy        #
##########################
variable "ecr_repo_arns" {
  description = "The list of policy statements for the Lambda execution role."
  type        = list(string)
  default     = []
}

variable "task_role_policy_arns" {
  description = "A map of policy names to policy ARNs to attach to the ECS Task IAM role."
  type        = map(string)
  default     = {}
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
