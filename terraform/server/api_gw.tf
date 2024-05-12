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

module "http_api_gateway" {
  source = "./http-api-gw"

  name        = "MyServiceAPI"
  description = "API Gateway for My Service."

  integrations = {
    "lambda_backend" = {
      type            = "AWS_PROXY"
      uri             = aws_lambda_function.my_lambda_function.invoke_arn
      payload_version = "2.0"
    },
    "http_backend" = {
      type            = "HTTP_PROXY"
      uri             = "https://examplebackend.com/"
      payload_version = "2.0"
    }
  }

  routes = {
    "get_lambda_data" = {
      route_key       = "GET /lambda"
      integration_key = "lambda_backend"
    },
    "get_http_data" = {
      route_key       = "GET /http"
      integration_key = "http_backend"
    }
  }

  stages = {
    "dev" = {
      auto_deploy = true
      logging     = {
        enabled        = true
        format         = "{\"requestId\":\"$context.requestId\", \"ip\":\"$context.identity.sourceIp\"}"
        retention_days = 14
      }
    },
    "prod" = {
      auto_deploy = true
    }
  }
}