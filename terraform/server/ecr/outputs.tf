########################
#         ECR          #
########################
output "repository_url" {
  value = aws_ecr_repository.ecr.repository_url
}

output "repository_name" {
  value = aws_ecr_repository.ecr.name
}

output "repository_arn" {
  description = "The Amazon Resource Name (ARN) of the created ECR repository."
  value       = aws_ecr_repository.ecr.arn
}

output "encryption_type" {
  description = "The encryption type of the ECR repository."
  value       = aws_ecr_repository.ecr.encryption_configuration[0].encryption_type
}

output "kms_key" {
  description = "The KMS key ID used for encrypting the ECR repository."
  value       = aws_ecr_repository.ecr.encryption_configuration[0].kms_key
}

output "ecr_lifecycle_policy" {
  description = "The lifecycle policy applied to the ECR repository"
  value       = aws_ecr_lifecycle_policy.ecr_lifecycle_policy[0].policy
}