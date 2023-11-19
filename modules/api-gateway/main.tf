########################
#   Resource Naming    #
########################
module "resource_naming" {
    source = "../resource-naming"
    tags = var.tags
}

########################
#     API Gateway      #
########################
resource "aws_apigatewayv2_api" "minecraft_http_api" {
  name          = "${module.resource_naming.name}-http-api-gw"
  protocol_type = "HTTP"
  tags          = var.tags
}

# Lambda integration for minecraft API Gateway
resource "aws_apigatewayv2_integration" "minecraft_lambda_integration" {
  api_id           = aws_apigatewayv2_api.minecraft_http_api.id
  description      = "Lambda integration for ${module.resource_naming.name} API Gateway"
  integration_type = "AWS_PROXY"
  connection_type        = "INTERNET"
  integration_method     = "POST"
  integration_uri        = var.lambda_invoke_arn
  payload_format_version = "2.0"
}

# Create a route in the API Gateway that accepts specified methods 
# and proxies them to the Lambda function
resource "aws_apigatewayv2_route" "minecraft_route" {
  api_id    = aws_apigatewayv2_api.minecraft_http_api.id
  route_key = "POST /command"
  target    = "integrations/${aws_apigatewayv2_integration.minecraft_lambda_integration.id}"
}

# Grant the API Gateway permission to invoke the Lambda function
resource "aws_lambda_permission" "minecraft_invoke_permission" {
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.minecraft_http_api.execution_arn}/*/*"
  # Tags are not applicable for aws_lambda_permission
}

# Stage to deploy in
resource "aws_apigatewayv2_stage" "minecraft_stage" {
  api_id      = aws_apigatewayv2_api.minecraft_http_api.id
  name        = var.label_id
  auto_deploy = true
  tags        = var.tags
}
