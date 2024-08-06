########################
#         SNS          #
########################
output "arn" {
  value       = aws_sns_topic.topic.arn
  description = "The ARN of the SNS topic"
}

output "name" {
  value       = aws_sns_topic.topic.name
  description = "The name of the SNS topic"
}
