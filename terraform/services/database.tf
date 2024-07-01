########################
#    DynamoDB Table    #
########################
module "dynamodb" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/dynamodb/aws"
  version = "0.0.1"

  name           = var.name
  billing_mode   = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "task_id"
  attributes = [
    { name = "task_id", type = "S" }
  ]
  ttl_enabled   = true
  ttl_attribute = "TTL"

  tags = module.tags.tags
}
