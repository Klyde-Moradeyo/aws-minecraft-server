########################
#  Cloud Watch Alarm   #
########################
output "alarm_id" {
  description = "The ID of the CloudWatch Alarm."
  value       = aws_cloudwatch_metric_alarm.default.id
}
