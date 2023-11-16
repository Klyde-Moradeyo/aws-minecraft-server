########################
#       Outputs        #
########################
output "vpc_id" {
  description = "The ID of the selected VPC."
  value       = local.vpc_id
}

output "subnet_id" {
  description = "The ID of the selected subnet."
  value       = local.subnet_id
}

output "igw_id" {
  description = "The ID of the Internet Gateway."
  value       = local.igw_id
}