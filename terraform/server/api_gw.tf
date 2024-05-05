########################
#     API Gateway      #
########################
module "api_gateway" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/api-gateway?ref=tf-modules"

  # lambda integration
  lambda_function_name = module.request_lambda.lambda_function_name
  lambda_invoke_arn    = module.request_lambda.lambda_function_invoke_arn

  # Module tags
  label_id = module.tags.label_id
  tags     = module.tags.tags
}