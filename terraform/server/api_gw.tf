########################
#     API Gateway      #
########################
module "api_gateway" {
  source = "./http-api-gw"

  name        = var.name
  description = "API Gateway for ${var.name}"

  stages = {
    "mango-minecraft-api" = {
      auto_deploy = true
      logging     = {
        enabled        = true
        retention_days = 60
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
      }
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
    }
  }

  tags = module.tags.tags
}