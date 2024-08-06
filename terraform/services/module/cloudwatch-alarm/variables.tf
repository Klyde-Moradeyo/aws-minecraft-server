########################
#    Resource Naming   #
########################
variable "name" {
  description = "The name of the resources"
  type        = string
}


########################
#  Cloud Watch Alarm   #
########################
variable "namespace" {
  type        = string
  description = "The namespace for the metric alarm."
}

variable "metric_name" {
  type        = string
  description = "The name of the metric."
}

variable "comparison_operator" {
  type        = string
  description = "The arithmetic operation to use when comparing the specified Statistic and Threshold."
}

variable "evaluation_periods" {
  type        = number
  description = "The number of periods over which data is compared to the specified threshold."
}

variable "period" {
  type        = number
  description = "The period in seconds over which the specified statistic is applied."
}

variable "threshold" {
  type        = number
  description = "The value against which the specified statistic is compared."
}

variable "statistic" {
  type        = string
  description = "The statistic to apply to the alarm's associated metric."
}

variable "actions_enabled" {
  type        = bool
  default     = true
  description = "Indicates whether or not actions should be executed during any changes to the alarm's state."
}

variable "alarm_actions" {
  type        = list(string)
  default     = []
  description = "The list of actions to execute when this alarm transitions into an ALARM state from any other state."
}

variable "ok_actions" {
  type        = list(string)
  default     = []
  description = "The list of actions to execute when this alarm transitions to an OK state from any other state."
}

variable "insufficient_data_actions" {
  type        = list(string)
  default     = []
  description = "The list of actions to execute when this alarm transitions to the INSUFFICIENT_DATA state from any other state."
}

variable "dimensions" {
  type = list(object({
    name  = string
    value = string
  }))
  default     = []
  description = "The dimensions for the alarm's associated metric."
}

########################
#         Tags         #
########################
variable "tags" {
  description = "Tags from tags module"
  type        = map(string)
}
