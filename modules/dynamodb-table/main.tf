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
#        DynamoDB      #
########################
resource "aws_dynamodb_table" "this" {
  name           = "${module.resource_name_prefix.resource_name}-${var.table_name}"
  billing_mode   = var.billing_mode
  hash_key       = var.hash_key
  range_key      = var.range_key
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity_units : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity_units : null


  attribute {
    name = var.hash_key
    type = "S"
  }

  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value["name"]
      type = attribute.value["type"]
    }
  }

  ttl {
    attribute_name = var.ttl_attribute
    enabled        = var.ttl_enabled
  }

  tags = var.tags
}
