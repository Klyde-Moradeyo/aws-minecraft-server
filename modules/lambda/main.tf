########################
#   Resource Naming    #
########################
module "resource_naming" {
  source = "../resource-naming"
  tags   = var.tags
}

########################
#    Lambda Function   #
########################
resource "aws_lambda_function" "lambda_function" {

  filename         = "./lambda_function_payload.zip"
  source_code_hash = filebase64sha256("./lambda_function_payload.zip") # Check the zip file SHA256 to for any changes
  function_name    = "${module.resource_naming.name}-lambda"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout

  environment {
    variables = {
      MC_SERVER_IP        = var.mc_server_ip
      MC_PORT             = var.mc_port
      SSM_GIT_PRIVATE_KEY = "/${var.ssm_git_private_key_name}"
      SSM_EC2_PRIVATE_KEY = "/${var.ssm_ec2_private_key_name}"
      EC2_INSTANCE_ID     = var.ec2_instance_id
      BOT_COMMAND_NAME    = "/${var.bot_command_name}"
      SUBNET_ID           = var.subnet_id         # These vars need to be changed in lambda python
      SECURITY_GROUP_ID   = var.security_group_id # These vars need to be changed in lambda python
      TF_USER_TOKEN       = var.terraform_token_name
      GIT_BRANCH          = var.git_branch # github branch to use
      S3_MC_WORLD_URI     = var.s3_minecraft_world_bucket_url
      S3_MC_ASSETS_URI    = var.s3_minecraft_assets_bucket_url

      # Tags
      TAGS_JSON = jsonencode(var.tags)
    }
  }

  layers = [
    local.git_lambda_layer_arn
  ]

  tags = var.tags
}

########################
#     Lambda Layer     #
########################
locals {
  git_lambda_layer_arn = "arn:aws:lambda:${var.aws_region}:553035198032:layer:git-lambda2:8"
}

# resource "aws_lambda_layer_version" "terraform_lambda_layer" {
#   filename   = "${path.module}/../../lambda/terraform_layer.zip"  # Replace with your layer ZIP filename
#   layer_name = "terraform_lambda_layer"
#   compatible_runtimes = [ "python3.8" ]  # Replace with your desired runtime
# }

