########################
#   Resource Naming    #
########################
module "resource_naming" {
  source = "../resource-naming"
  tags   = var.tags
}

########################
#        DynamoDB      #
########################
resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = var.hash_key
  range_key    = var.range_key

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

  dynamic "provisioned_throughput" {
    for_each = var.billing_mode == "PROVISIONED" ? [1] : []
    content {
      read_capacity_units  = var.read_capacity_units
      write_capacity_units = var.write_capacity_units
    }
  }

  ttl {
    attribute_name = var.ttl_attribute
    enabled        = var.ttl_enabled
  }

  tags = var.tags
}
