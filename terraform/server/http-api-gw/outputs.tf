output "api_id" {
  value       = aws_apigatewayv2_api.http_api.id
  description = "The ID of the HTTP API."
}

output "api_endpoint" {
  value       = aws_apigatewayv2_api.http_api.api_endpoint
  description = "The endpoint through which the HTTP API can be accessed."
}

output "stage_invoke_urls" {
  value = {
    for k, v in aws_apigatewayv2_stage.api_stages : k => {
      "stage_name" = k
      "url"        = "https://${aws_apigatewayv2_api.http_api.api_id}.execute-api.${var.region}.amazonaws.com/${k}"
    }
  }
  description = "A map containing the invoke URLs for each stage."
}

output "integrations_details" {
  value = {
    for k, v in aws_apigatewayv2_integration.api_integrations : k => {
      "integration_id"   = v.id
      "integration_type" = v.integration_type
      "integration_uri"  = v.integration_uri
    }
  }
  description = "Details of each integration used in the API."
}

output "route_details" {
  value = {
    for k, v in aws_apigatewayv2_route.api_routes : k => {
      "route_id"    = v.id
      "route_key"   = v.route_key
      "target"      = v.target
    }
  }
  description = "Details of each route configured in the API."
}

output "log_group_details" {
  value = {
    for k, v in aws_cloudwatch_log_group.api_log_group : k => {
      "log_group_name" = v.name
      "log_group_arn"  = v.arn
    }
  }
  description = "The names and ARNs of the CloudWatch log groups associated with each stage that has logging enabled."
}

