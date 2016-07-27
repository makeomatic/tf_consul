provider "aws" {
    region = "${var.region}"
}

# Instance created for default VPC.
resource "aws_instance" "server" {
    count = "${var.servers * var.default-vpc}"

    ami = "${data.null_data_source.aws-eval.outputs.ami}"
    instance_type = "${var.instance_type}"
    key_name = "${var.key_name}"

    # Use given availability zone or choose automatically in round-roubin manner,
    # when cross_zone_distribution is enabled.
    availability_zone = "${element(
        concat(
            list(var.availability_zone),
            var.region_avzones[var.region]
        ),  (count.index + 1) * var.cross_zone_distribution
    )}"

    # Default VPC uses security group names!
    security_groups = [
        "${concat(list(aws_security_group.consul.name), var.security_groups)}"
    ]

    connection {
        user = "${data.null_data_source.aws-eval.outputs.user}"
        key_file = "${var.key_path}"
    }

    tags {
        Name = "${var.tagName}-${count.index}"
    }

    # Install docker
    provisioner "remote-exec" {
        inline = [
            ". /etc/profile",
            "curl -V &>/dev/null && ( curl -sSL https://get.docker.com/ | sh",
            "wget -V &>/dev/null && ( wget -qO- https://get.docker.com/ | sh",
            "sudo usermod -aG docker $(id -un)",
            "${var.helper-commands["remove-ecs-agent"]}"
        ]
    }
}

# Instance created for non-default VPC.
resource "aws_instance" "vpc-server" {
    count = "${var.servers * (1 - var.default-vpc)}"

    ami = "${data.null_data_source.aws-eval.outputs.ami}"
    instance_type = "${var.instance_type}"
    key_name = "${var.key_name}"

    # Use subnet_id provided our choose from subnet_ids list in round-robin manner
    subnet_id = "${ coalesce(var.subnet_id, element(var.subnet_ids, count.index)) }"

    # Use given availability zone or choose automatically in round-roubin manner,
    # when cross_zone_distribution is enabled.
    availability_zone = "${element(
        concat(
            list(var.availability_zone),
            var.region_avzones[var.region]
        ),  (count.index + 1) * var.cross_zone_distribution
    )}"

    # Non-default VPC uses security group IDs!
    vpc_security_group_ids = [
        "${concat(list(aws_security_group.consul.id), var.security_groups)}"
    ]

    connection {
        user = "${data.null_data_source.aws-eval.outputs.user}"
        key_file = "${var.key_path}"
    }

    tags {
        Name = "${var.tagName}-${count.index}"
    }

    # Install docker
    provisioner "remote-exec" {
        inline = [
            ". /etc/profile",
            "curl -V &>/dev/null && ( curl -sSL https://get.docker.com/ | sh )",
            "wget -V &>/dev/null && ( wget -qO- https://get.docker.com/ | sh )",
            "sudo usermod -aG docker $(id -un)",
            "${var.helper-commands["remove-ecs-agent"]}"
        ]
    }
}

# Start consul container
resource "null_resource" "start-consul" {
    count = "${var.servers}"
    triggers {
        id = "${element(concat(aws_instance.server.*.id, aws_instance.vpc-server.*.id), count.index)}"
    }

    connection {
        host = "${element(
            concat(aws_instance.server.*.public_ip, aws_instance.vpc-server.*.public_ip),
            count.index)}"
        user = "${data.null_data_source.aws-eval.outputs.user}"
        key_file = "${var.key_path}"
    }

    provisioner "remote-exec" {
        inline = [
            ". /etc/profile",
            "${data.template_file.consul_server.rendered}"
        ]
    }
}

# Defines template for docker run command
data "template_file" "consul_server" {
    template = "${file("${path.module}/../templates/consul-server.tmpl")}"
    vars {
        image = "${var.image}"
        args  = "${var.args}"
        dns_port = "${var.dns_port}"
        advertise_interface = "${var.advertise_interface}"

        # Grab any node created first.
        default_args = "-bootstrap-expect ${var.servers} -join ${
            element(concat(
                        aws_instance.server.*.private_ip,
                        aws_instance.vpc-server.*.private_ip),
                    0)
            }"
    }
}