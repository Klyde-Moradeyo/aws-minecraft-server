output "metric_alarm_names" {
  value       = [for alarm in aws_cloudwatch_metric_alarm.alarm : alarm.alarm_name]
  description = "The names of the CloudWatch metric alarms."
}

output "metric_alarm_arns" {
  value       = [for alarm in aws_cloudwatch_metric_alarm.alarm : alarm.arn]
  description = "The ARNs of the CloudWatch metric alarms."
}
