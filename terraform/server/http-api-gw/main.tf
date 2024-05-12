##########################
#     Naming Config      #
##########################
module "resource_name_prefix" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/resource-name-prefix/aws"
  version = "0.0.1"

  name = var.name
  tags = var.tags
}

##########################
#       HTTP API         #
##########################
locals {
  api_name = "${module.resource_name_prefix.resource_name}-http-api-gw"
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = local.api_name
  protocol_type = "HTTP"
  description   = var.description
  tags = var.tags
}

resource "aws_apigatewayv2_integration" "api_integrations" {
  for_each = var.integrations

  api_id               = aws_apigatewayv2_api.http_api.id
  integration_type     = each.value.type
  integration_uri      = each.value.uri
  payload_format_version = each.value.payload_version
}

resource "aws_apigatewayv2_route" "api_routes" {
  for_each = var.routes

  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = each.value.route_key
  target    = "integrations/${aws_apigatewayv2_integration.api_integrations[each.value.integration_key].id}"
}

resource "aws_apigatewayv2_stage" "api_stages" {
  for_each = var.stages

  api_id      = aws_apigatewayv2_api.http_api.id
  name        = each.key
  auto_deploy = each.value.auto_deploy

  dynamic "access_log_settings" {
    for_each = each.value.logging != null && each.value.logging.enabled ? [1] : []
    content {
      destination_arn = module.cloudwatch_log[each.key].arn
      format          = each.value.logging.format
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

