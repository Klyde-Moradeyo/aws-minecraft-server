##########################
#     Naming Config      #
##########################
module "resource_name_prefix" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/resource-name-prefix/aws"
  version = "0.0.1"

  name = var.name
  tags = var.tags
}

########################
#   Cloud Watch logs   #
########################A
locals {
  // List of prefixes that should omit the "-logs" suffix
  prefix_list = ["/aws/lambda/"]

  // Determine the log group name based on whether var.name starts with any of the specified prefixes
  starts_with_prefix = anytrue([for prefix in local.prefix_list : startswith(var.name, prefix)])
  log_group_name     = local.starts_with_prefix ? "${var.name}" : "${module.resource_name_prefix.resource_name}-logs"
}


resource "aws_cloudwatch_log_group" "log_group" {
  name              = local.log_group_name
  retention_in_days = var.retention_in_days

  tags = var.tags
}

resource "aws_cloudwatch_log_resource_policy" "resource_policy" {
  for_each        = { for policy in var.resource_policies : policy.name => policy }
  policy_name     = "${module.resource_name_prefix.resource_name}-${each.value.name}-policy"
  policy_document = each.value.document
}

resource "aws_cloudwatch_log_subscription_filter" "subscription_filter" {
  for_each        = { for filter in var.subscription_filters : filter.name => filter }
  name            = "${module.resource_name_prefix.resource_name}-${each.value.name}-sub-filter"
  log_group_name  = aws_cloudwatch_log_group.log_group.name
  filter_pattern  = each.value.pattern
  destination_arn = each.value.destination_arn
  role_arn        = each.value.role_arn
  distribution    = each.value.distribution
}


