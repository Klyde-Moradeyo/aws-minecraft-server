output "info" {
  value = { for key, data in aws_ssm_parameter.param : key => {
    id          = data.id
    name        = data.name
    description = data.description
    type        = data.type
    arn         = data.arn
    key_id      = data.key_id
    overwrite   = data.overwrite
  }}
  description = "Details of each SSM parameter created by the module, including IDs, names, types, and ARNs."
}
