output "id" {
  value = aws_api_gateway_rest_api.api.id
}

output "execution_arn" {
  value = aws_api_gateway_rest_api.api.execution_arn
}

output "stage_url" {
  value = "${aws_api_gateway_deployment.api_deployment.invoke_url}/${aws_api_gateway_stage.api_stage.stage_name}"
}
