########################
#     API Gateway      #
########################
# module "api_gateway" {
#   source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/api-gateway?ref=tf-modules"

#   # lambda integration
#   lambda_function_name = module.request_lambda.name
#   lambda_invoke_arn    = module.request_lambda.arn

#   # Module tags
#   tags = module.tags.tags
# }

module "api_gateway" {
  source = "./http-api-gw"

  name        = var.name
  description = "${var.name} HTTP API Gateway"
  endpoint_type = "REGIONAL"

  log_retention_days = 7

  resources = [
    {
      path_part   = "minecraft-server/prod/command"
      http_method = "POST"
      target_url  = module.request_lambda.invoke_arn
    }
  ]

  stages = [
    {
      name        = "prod"
      description = "Production stage for Minecraft API"
    }
  ]

  tags = module.tags.tags
}

resource "aws_lambda_permission" "api_gw_lambda_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.request_lambda.name
  principal     = "apigateway.amazonaws.com"
  source_arn    = module.api_gateway.execution_arn
}


output "api_gateway_url_dev" {
  value = "${module.api_gateway.api_gateway_stage_url["dev"]}"
}

output "api_gateway_url_prod" {
  value = "${module.api_gateway.api_gateway_stage_url["prod"]}"
}
