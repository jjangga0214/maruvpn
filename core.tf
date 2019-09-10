resource "aws_key_pair" "key_pair" {
  key_name   = var.aws_key_pair_name
  public_key = "${file(var.ssh_public_key_path)}"
}

resource "aws_instance" "openvpn_access_server" {
  ami                         = var.aws_amis[var.aws_region]
  instance_type               = var.aws_instance_type
  subnet_id                   = "${aws_subnet.subnet.id}"
  vpc_security_group_ids      = ["${aws_security_group.allow_openvpn.id}", "${aws_security_group.allow_basic.id}"]
  associate_public_ip_address = "true"
  key_name                    = "${aws_key_pair.key_pair.key_name}"

  tags = {
    Name  = "maruvpn-ec2-openvpn-access-server"
    Owner = "maruvpn"
  }

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = "${file(var.ssh_private_key_path)}"
    host        = "${aws_instance.openvpn_access_server.public_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y docker.io",
      "sudo mkdir -p /maruvpn/config",
      "sudo chown -hR $USER:$USER /maruvpn",
      "sudo chmod -R 777 /maruvpn"
    ]
  }

  provisioner "file" {
    source      = "docker-run.sh"
    destination = "/maruvpn/docker-run.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /maruvpn/docker-run.sh",
      "sudo /maruvpn/docker-run.sh Europe/London",
    ]
  }
}

# resource "docker_image" "openvpn_as" {
#   name = "linuxserver/openvpn-as"
# }

# # Creates a docker volume
# resource "docker_volume" "openvpn_as_config" {
#   name = "openvpn-as-config"
# }

# # Create a container
# resource "docker_container" "openvpn_as" {
#   image    = "${docker_image.openvpn_as.latest}"
#   name     = "openvpn-as"
#   restart  = "unless-stopped"
#   start    = "true"
#   must_run = "true"
#   env      = ["PUID=1000", "PGID=1000", "TZ=Europe/London"]
#   ports {
#     external = 943
#     internal = 943
#   }
#   ports {
#     external = 9443
#     internal = 9443
#   }
#   ports {
#     external = 1194
#     internal = 1194
#     protocol = "udp"
#   }
#   volumes {
#     container_path = "/config"
#     volume_name    = "${docker_volume.openvpn_as_config.name}"
#   }
# }
