########################
#        Lambda        #
########################
output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.lambda_function.arn
}

output "lambda_function_invoke_arn" {
  description = "The Invoke ARN of the Lambda function"
  value       = aws_lambda_function.lambda_function.invoke_arn
}

output "lambda_function_name" {
  description = "Lambda function Name"
  value       = aws_lambda_function.lambda_function.function_name
}

output "iam_role_arn" {
  description = "The ARN of the IAM role for Lambda"
  value       = aws_iam_role.iam_for_lambda.arn
}