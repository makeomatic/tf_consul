provider "aws" {
    region = "${var.region}"
}

# Instance created for default VPC.
resource "aws_instance" "server" {
    count = "${var.servers * var.default-vpc}"

    ami = "${data.null_data_source.aws.outputs.ami}"
    instance_type = "${var.instance_type}"
    key_name = "${var.key_name}"

    lifecycle {
        ignore_changes = [ "${var.ignore_changes}" ]
    }

    # RR cross-zone distribution is enabled by default.
    # Either set var.zone or set var.cross_zone_distribution to false to disable!
    availability_zone = "${coalesce(
            var.availability_zone,
            element(
                data.aws_availability_zones.available.names,
                count.index * var.cross_zone_distribution
            )
        )}"

    # Use names for the default VPC.
    security_groups = [
        "${concat(
                var.security_groups,
                list(aws_security_group.consul.name,
                     aws_security_group.nomad.name,
                     aws_security_group.swarm.name)
        )}"
    ]

    tags {
        Name = "${data.null_data_source.consul.outputs.instance_name}-${count.index}"
    }

    # Pass user-data which is a merged cloud-init yaml
    user_data = "${data.template_cloudinit_config.default.rendered}"
}

# Instance created for non-default VPC.
resource "aws_instance" "vpc-server" {
    count = "${var.servers * (1 - var.default-vpc)}"

    ami = "${data.null_data_source.aws.outputs.ami}"
    instance_type = "${var.instance_type}"
    key_name = "${var.key_name}"

    lifecycle {
        ignore_changes = [ "${var.ignore_changes}" ]
    }

    # Use subnet_id provided our choose from subnet_ids list in round-robin manner
    subnet_id = "${ coalesce(var.subnet_id, element(var.subnet_ids, count.index)) }"

    # RR cross-zone distribution is enabled by default.
    # Either set var.zone or set var.cross_zone_distribution to false to disable!
    availability_zone = "${coalesce(
            var.availability_zone,
            element(
                data.aws_availability_zones.available.names,
                count.index * var.cross_zone_distribution
            )
        )}"

    # Non-default VPC uses security group IDs!
    vpc_security_group_ids = [
        "${concat(
                var.security_groups,
                list(aws_security_group.consul.id,
                     aws_security_group.nomad.id,
                     aws_security_group.swarm.id)
        )}"
    ]

    tags {
        Name = "${data.null_data_source.consul.outputs.instance_name}-${count.index}"
    }

    # Pass user-data which is a merged cloud-init yaml
    user_data = "${data.template_cloudinit_config.default.rendered}"
}


# Write consul input.json configuration file
#
resource "null_resource" "input_file" {
    count = "${var.servers}"

    triggers {
        seed_id = "${element(concat(aws_instance.server.*.id, aws_instance.vpc-server.*.id), 0)}"
    }

    connection {
        host = "${
            element(
                concat(aws_instance.server.*.public_ip, aws_instance.vpc-server.*.public_ip),
                count.index
            )}"
        user = "${data.null_data_source.aws.outputs.user}"
        private_key = "${file(var.key_path)}"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo mkdir -p /var/lib/terraform/consul",
            "sudo chown $(id -un):$(id -gn) /var/lib/terraform/consul"
        ]
    }

    provisioner "file" {
        content = "${jsonencode(data.null_data_source.input.outputs)}"
        destination = "/var/lib/terraform/consul/input.json"
    }
}


# Input required for consul and nomad
#
data "null_data_source" "input" {
    inputs {
        # Address of the first created node - all others connect to the seeder.
        seed_address = "${element(concat(aws_instance.server.*.public_ip, aws_instance.vpc-server.*.public_ip), 0)}"
        servers = "${var.servers}"
        advertise_ipnum = "${var.advertise_ipnum}"

        # Consul specific
        consul_image = "${var.consul_image}"
        consul_args = "${var.consul_args}"
        consul_dnsport = "${var.consul_dnsport}"

        # Nomad specfic
        nomad_enabled = "${var.nomad_enabled}"
        nomad_image = "${var.nomad_image}"
        nomad_region = "${var.nomad_region}"
        nomad_datacenter = "${var.nomad_datacenter}"

        # Swarm
        swarm_enabled = "${var.swarm_enabled}"
        swarm_image = "${var.swarm_image}"
        swarm_managerport = "${var.swarm_managerport}"
    }
}


# Compound cloud-init config
#
data "template_cloudinit_config" "default" {
    gzip          = false
    base64_encode = false

    part {
        filename = "include-list.cc"
        content_type = "text/x-include-url"
        content      = "${file("${path.module}/../include-list.cc")}"
    }

    part {
        content_type = "text/cloud-config"
        content      = "${data.template_file.user-data.rendered}"
    }
}


# User-Data template
#
data "template_file" "user-data" {
    template = "${file("${path.module}/../templates/user-data.cc.tmpl")}"
    vars {
        start-consul-content = "${file("${path.module}/../scripts/start-consul.sh")}"
        start-nomad-content = "${file("${path.module}/../scripts/start-nomad.sh")}"
        start-swarm-content = "${file("${path.module}/../scripts/start-swarm.sh")}"
        nomad-conf-content = "${file("${path.module}/../templates/nomad.conf.hcl.tmpl")}"
    }
}
