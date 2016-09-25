
output "security_group_id" {
    value = "${aws_security_group.consul.id}"
}

output "security_groups" {
    value = ["${concat(aws_instance.server.*.security_groups, aws_instance.server.*.vpc_security_group_ids)}"]
}

output "private_ips" {
    value = ["${concat(aws_instance.server.*.private_ip, aws_instance.vpc-server.*.private_ip)}"]
}

output "public_ips" {
    value = ["${concat(aws_instance.server.*.public_ip, aws_instance.vpc-server.*.public_ip)}"]
}
