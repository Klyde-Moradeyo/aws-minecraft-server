locals {
  cluster_name = split("/", element(split(":", var.cluster_arn), 5))[1]
}