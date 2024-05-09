output "log_group_name" {
  value = aws_cloudwatch_log_group.log_group.name
}

output "log_group_arn" {
  value = aws_cloudwatch_log_group.log_group.arn
}

output "log_resource_policies" {
  value       = [for policy in aws_cloudwatch_log_resource_policy.resource_policy : policy.policy_name]
  description = "The names of the CloudWatch log resource policies."
}

output "subscription_filters" {
  value       = [for filter in aws_cloudwatch_log_subscription_filter.subscription_filter : filter.name]
  description = "The names of the CloudWatch Log subscription filters."
}
