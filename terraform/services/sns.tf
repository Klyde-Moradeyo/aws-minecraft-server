module "sns" {
  source = "./module/sns"

  name = var.name
  subscriptions = [
    {
      protocol = "email"
      endpoint = "klyde.moradeyo.dev@gmail.com"
    }
  ]

  tags = module.tags.tags
}