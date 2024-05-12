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
  description = "API Gateway for ${var.name}"

  integrations = {
    "lambda_backend" = {
      type            = "AWS_PROXY"
      uri             = module.request_lambda.invoke_arn
      payload_version = "2.0"
    }
  }

  routes = {
    "get_lambda_data" = {
      route_key       = "POST /command"
      integration_key = "lambda_backend"
    }
  }

  stages = {
    "mango-minecraft-api" = {
      auto_deploy = true
      logging     = {
        enabled        = true
        format = jsonencode({
          requestId          = "$context.requestId",
          ip                 = "$context.identity.sourceIp",
          caller             = "$context.identity.caller",
          user               = "$context.identity.user",
          requestTime        = "$context.requestTime",
          httpMethod         = "$context.httpMethod",
          resourcePath       = "$context.resourcePath",
          status             = "$context.status",
          protocol           = "$context.protocol",
          responseLength     = "$context.responseLength",
          integrationLatency = "$context.integrationLatency",
          backendLatency     = "$context.responseLatency"
        })
        retention_days = 60
      }
    }
  }

  tags = module.tags.tags
}