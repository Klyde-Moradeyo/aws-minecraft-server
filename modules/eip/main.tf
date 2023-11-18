########################
#         EIP          #
########################
resource "aws_eip" "mc_server_eip" {
  domain = "vpc"

  tags = var.tags
}