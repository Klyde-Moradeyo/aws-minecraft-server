########################
#     API Gateway      #
########################
module "api_gateway" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/api-gateway?ref=tf-modules"

  # lambda integration
  lambda_function_name = module.request_lambda.name
  lambda_invoke_arn    = module.request_lambda.arn

  # Module tags
  tags = module.tags.tags
}