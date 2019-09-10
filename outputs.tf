output "ip" {
  value = aws_instance.openvpn_access_server.public_ip
}
output "domain" {
  value = aws_instance.openvpn_access_server.public_dns
}
output "instance_id" {
  value = aws_instance.openvpn_access_server.id
}
output "az" {
  value = aws_instance.openvpn_access_server.availability_zone
}
