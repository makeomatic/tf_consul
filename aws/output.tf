
output "security_group_id" {
    value = "${aws_security_group.consul.id}"
}

output "private_ips" {
    value = ["${concat(aws_instance.server.*.private_ip, aws_instance.vpc-server.*.private_ip)}"]
}

output "public_ips" {
    value = ["${concat(aws_instance.server.*.public_ip, aws_instance.vpc-server.*.public_ip)}"]
}
