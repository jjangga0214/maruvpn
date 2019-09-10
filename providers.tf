provider "aws" {
  # profile    = "default"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
  version    = "~> 2.0"
}

# provider "docker" {
#   host       = "tcp://${aws_instance.openvpn_access_server.public_ip}:2376/"
#   depends_on = [aws_instance.openvpn_access_server]
#   version    = "~> 2.0"
# }
