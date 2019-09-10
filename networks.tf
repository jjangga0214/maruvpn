resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = "true"

  tags = {
    Name  = "maruvpn-vpc"
    Owner = "maruvpn"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name  = "maruvpn-igw"
    Owner = "maruvpn"
  }
}

# Define the route table
resource "aws_route_table" "rt" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    # ipv6_cidr_block can only used to egress only internet gateway.
    # refer: https://github.com/hashicorp/terraform/issues/13363
    # ipv6_cidr_block = "::/0"
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name  = "maruvpn-rt"
    Owner = "maruvpn"
  }

}

resource "aws_subnet" "subnet" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.0.0/24"

  availability_zone       = var.aws_az
  map_public_ip_on_launch = "true"

  tags = {
    Name  = "maruvpn-subnet"
    Owner = "maruvpn"
  }

}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "rt_subnet_association" {
  subnet_id      = "${aws_subnet.subnet.id}"
  route_table_id = "${aws_route_table.rt.id}"
}

resource "aws_security_group" "allow_basic" {
  name        = "maruvpn-sg-allow-basic"
  description = "Allow icmp, ssh inbound and unlimited outbound traffic"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    # ref: https://github.com/hashicorp/terraform/issues/1313
    from_port        = 8
    to_port          = 0
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    # every ports, all protocol is allowed to all destination cidr
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name  = "maruvpn-sg-allow-basic"
    Owner = "maruvpn"
  }
}

resource "aws_security_group" "allow_openvpn" {
  name        = "maruvpn-sg-allow-openvpn"
  description = "Allow openvpn inbound"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port        = 943
    to_port          = 943
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 9443
    to_port          = 9443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 1194
    to_port          = 1194
    protocol         = "udp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name  = "maruvpn-sg-allow-openvpn"
    Owner = "maruvpn"
  }

}
