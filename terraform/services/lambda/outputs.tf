output "name" {
  description = "The name of the Lambda function."
  value       = aws_lambda_function.lambda.function_name
}

output "arn" {
  description = "The ARN of the Lambda function."
  value       = aws_lambda_function.lambda.arn
}

output "invoke_arn" {
  description = "The Invoke ARN of the Lambda function."
  value       = aws_lambda_function.lambda.invoke_arn
}

output "iam_role_arn" {
  description = "The IAM role for the Lambda function."
  value       = module.iam_role.iam_role_arn
}

output "iam_role_name" {
  description = "The IAM role for the Lambda function."
  value       = module.iam_role.iam_role_name
}

output "image_uri" {
  description = "The image URI of the Lambda function."
  value       = aws_lambda_function.lambda.image_uri
}

output "zip_file" {
  description = "The local ZIP file path of the Lambda function."
  value       = aws_lambda_function.lambda.filename
}
