variable "aws_region" {
  default = "ap-northeast-2"
}
variable "aws_az" {
  default = "ap-northeast-2c"
}

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "aws_instance_type" {
  default = "t2.micro"
}
variable "aws_key_pair_name" {
  default = "maruvpn-keypair"
}

variable "ssh_public_key_path" {}
variable "ssh_private_key_path" {}
variable "ssh_user" {}

variable "aws_amis" {
  type = "map"
  # Ubuntu Server 18.04 LTS
  default = {
    "us-east-1"      = "ami-b374d5a5"
    "us-west-2"      = "ami-4b32be2b"
    "ap-northeast-2" = "ami-0fd02cb7da42ee5e0"
  }
}

variable "port" {
  type    = number
  default = 1194
}

variable "protocol" {
  default = "udp"
}
variable "protocol_choice" {
  type = "map"
  default = {
    "udp" = "1"
    "tcp" = "2"
  }
}

variable "dns" {
  default = "CLOUDFLARE"
}

variable "dns_choice" {
  type = "map"
  default = {
    "CLOUDFLARE" = "3"
    "OPENDNS"    = "8"
    "GOOGLE"     = "9"
  }
}


variable "yn_choice" {
  type = "map"
  default = {
    true  = "y"
    false = "n"
  }
}

variable "enable_compression" {
  type    = bool
  default = false
}

variable "customize_encryption" {
  type    = bool
  default = false
}

variable "client" {
  default = "client"
}
