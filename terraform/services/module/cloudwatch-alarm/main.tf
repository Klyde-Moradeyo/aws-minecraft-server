########################
#   Resource Naming    #
########################
module "resource_name_prefix" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/resource-name-prefix/aws"
  version = "0.0.1"

  name = var.name
  tags = var.tags
}


########################
#  Cloud Watch Alarm   #
########################
resource "aws_cloudwatch_metric_alarm" "default" {
  alarm_name                = "${module.resource_name_prefix.resource_name}-alarm"
  namespace                 = var.namespace
  metric_name               = var.metric_name
  comparison_operator       = var.comparison_operator
  evaluation_periods        = var.evaluation_periods
  period                    = var.period
  threshold                 = var.threshold
  statistic                 = var.statistic
  actions_enabled           = var.actions_enabled
  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
  tags                      = var.tags

   dimensions = { for d in var.dimensions : d.name => d.value }
}

