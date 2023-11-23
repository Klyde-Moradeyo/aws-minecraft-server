########################
#         Tags         #
########################
variable "tags" {
  description = "Tags from tags module"
  type        = map(string)
}

########################
#         ECR          #
########################
variable "repo_name" {
  description = "ECR Repo Name"
  type        = string
}
