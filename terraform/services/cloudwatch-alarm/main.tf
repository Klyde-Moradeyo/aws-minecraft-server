##########################
#     Naming Config      #
##########################
module "resource_name_prefix" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/resource-name-prefix/aws"
  version = "0.0.1"

  name = var.name
  tags = var.tags
}

########################
#  Cloud Watch Alarm   #
########################
resource "aws_cloudwatch_metric_alarm" "alarm" {
  for_each = { for alarm in var.metric_alarms : alarm.name => alarm }

  alarm_name                            = "${module.resource_name_prefix.resource_name}-${each.value.name}-alarm"
  comparison_operator                   = each.value.comparison_operator
  evaluation_periods                    = each.value.evaluation_periods
  metric_name                           = each.value.metric_name
  namespace                             = each.value.namespace
  period                                = each.value.period
  statistic                             = lookup(each.value, "statistic", "Average")
  threshold                             = each.value.threshold
  actions_enabled                       = lookup(each.value, "actions_enabled", true)
  alarm_description                     = lookup(each.value, "description", "")
  datapoints_to_alarm                   = lookup(each.value, "datapoints_to_alarm", each.value.evaluation_periods)
  dimensions                            = lookup(each.value, "dimensions", {})
  evaluate_low_sample_count_percentiles = lookup(each.value, "evaluate_low_sample_count_percentiles", "")
  extended_statistic                    = lookup(each.value, "extended_statistic", "")
  insufficient_data_actions             = lookup(each.value, "insufficient_data_actions", [])
  ok_actions                            = lookup(each.value, "ok_actions", [])
  treat_missing_data                    = lookup(each.value, "treat_missing_data", "missing")
  unit                                  = lookup(each.value, "unit", "")

  alarm_actions = lookup(each.value, "alarm_actions", [])

  tags = var.tags
}



