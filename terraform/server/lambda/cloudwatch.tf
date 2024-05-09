module "cloudwatch_log" {
    source = "../cloudwatch-log-group"

    name = var.name
    retention_in_days = 30
    tags = var.tags
}