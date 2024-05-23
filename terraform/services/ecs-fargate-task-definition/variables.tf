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

##########################
#      IAM Policy        #
##########################
variable "ecr_repo_arns" {
  description = "The list of policy statements for the Lambda execution role."
  type        = list(string)
  default = []
}

variable "task_role_policy_arns" {
  description = "A map of policy names to policy ARNs to attach to the ECS Task IAM role."
  type        = map(string)
  default = {}
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
