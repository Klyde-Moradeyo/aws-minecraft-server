########################
#   Resource Naming    #
########################
module "resource_name_prefix" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/resource-name-prefix/aws"
  version = "0.0.1"

  name = var.name
  tags = var.tags
}

########################
#         SNS          #
########################
resource "aws_sns_topic" "topic" {
  name              = "${module.resource_name_prefix.resource_name}-topic"
  display_name      = var.display_name
  kms_master_key_id = var.kms_master_key_id
  policy            = var.policy

  tags = var.tags
}

resource "aws_sns_topic_subscription" "topic_subscription" {
  count = length(var.subscriptions)

  topic_arn = aws_sns_topic.this.arn
  protocol  = var.subscriptions[count.index]["protocol"]
  endpoint  = var.subscriptions[count.index]["endpoint"]

  confirmation_timeout_in_minutes = lookup(var.subscriptions[count.index], "confirmation_timeout_in_minutes", null)
  raw_message_delivery            = lookup(var.subscriptions[count.index], "raw_message_delivery", null)
  filter_policy                   = lookup(var.subscriptions[count.index], "filter_policy", null)
}