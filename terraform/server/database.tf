########################
#    DynamoDB Table    #
########################
module "dynamodb_table" {
  source = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git//modules/dynamodb-table?ref=tf-modules"

  table_name = "mc-server-worker"
  hash_key   = "task_id"
  attributes = [
    { name = "task_id", type = "S" },
  ]
  read_capacity_units  = 10
  write_capacity_units = 10
  ttl_enabled          = true
  ttl_attribute        = "TTL"
  tags                 = module.tags.tags
}