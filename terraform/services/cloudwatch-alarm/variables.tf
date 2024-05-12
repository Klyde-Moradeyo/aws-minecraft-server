########################
#    Resource Naming   #
########################
variable "name" {
  description = "The base name of the resources"
  type        = string
}

########################
#  Cloud Watch Alarm   #
########################
variable "metric_alarms" {
  description = "A list of CloudWatch metric alarms"
  type = list(object({
    name                                = string
    comparison_operator                 = string
    evaluation_periods                  = number
    metric_name                         = string
    namespace                           = string
    period                              = number
    threshold                           = number
    actions_enabled                     = optional(bool, true)
    description                         = optional(string, "")
    datapoints_to_alarm                 = optional(number)
    dimensions                          = optional(map(string), {})
    evaluate_low_sample_count_percentiles = optional(string, "")
    extended_statistic                  = optional(string, "")
    insufficient_data_actions           = optional(list(string), [])
    ok_actions                          = optional(list(string), [])
    treat_missing_data                  = optional(string, "missing")
    unit                                = optional(string, "")
    alarm_actions                       = optional(list(string), [])
  }))
}

########################
#         Tags         #
########################
variable "tags" {
  description = "Tags from labels module"
  type        = map(string)
}
