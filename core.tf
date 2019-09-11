resource "random_string" "ssh_keys" {
  length  = 24
  special = false
  keepers = {
    # Generate a new id each time we switch to a new AMI id
    ssh_public_key    = "${file(var.ssh_public_key_path)}"
    ssh_private_key   = "${file(var.ssh_private_key_path)}"
    aws_key_pair_name = var.aws_key_pair_name
  }
}

resource "aws_key_pair" "key_pair" {
  key_name = "${random_string.ssh_keys.keepers.aws_key_pair_name}-${random_string.ssh_keys.result}"
  # Read the public_key "through" the random_string resource to ensure that
  # both will change together.
  public_key = "${random_string.ssh_keys.keepers.ssh_public_key}"
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
    private_key = "${random_string.ssh_keys.keepers.ssh_private_key}"
    host        = "${aws_instance.openvpn_access_server.public_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo mkdir /maruvpn",
      "sudo chown -hR $USER:$USER /maruvpn",
      "sudo chmod -R 777 /maruvpn"
    ]
  }

  provisioner "file" {
    source      = "openvpn-install/openvpn-install.sh"
    destination = "/maruvpn/openvpn-install.sh"
  }

  # Install openvpn and create ${var.client}.ovpn file (under home(~) directory)
  ## Client is passwordless($PASS=1 (default))
  ## PORT_CHOICE=2 enables custom PORT configuration
  ## If COMPRESSION_ENABLED is enabled, COMPRESSION_CHOICE and COMPRESSION_ALG should be configured
  provisioner "remote-exec" {

    inline = [<<-EOF

      sudo chmod +x /maruvpn/openvpn-install.sh
      sudo \
      AUTO_INSTALL=y \
      ENDPOINT=${aws_instance.openvpn_access_server.public_ip} \
      IPV6_SUPPORT=n \
      PORT_CHOICE=2 \
      PORT=${var.port} \
      PROTOCOL_CHOICE=${var.protocol_choice[var.protocol]} \
      DNS=${var.dns_choice[var.dns]} \
      COMPRESSION_ENABLED=${var.yn_choice[var.enable_compression]} \
      CUSTOMIZE_ENC=${var.yn_choice[var.customize_encryption]} \
      CLIENT=${var.client} \
      /maruvpn/openvpn-install.sh
      
    EOF
    ]
  }
}
