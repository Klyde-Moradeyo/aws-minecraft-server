output "id" {
  description = "The ID of the created AWS EC2 instance."
  value       = aws_instance.ec2_instance.id
}

output "public_ip" {
  description = "The public IP address assigned to the EC2 instance."
  value       = aws_instance.ec2_instance.public_ip
}

output "subnet_id" {
  description = "The ID of the subnet in which the EC2 instance is deployed."
  value       = var.subnet_id
}

output "ec2_instance_id" {
  description = "The unique identifier of the AWS EC2 instance."
  value       = aws_instance.ec2_instance.id
}

output "ec2_instance_arn" {
  description = "The arn of the AWS EC2 instance."
  value       = aws_instance.ec2_instance.arn
}
