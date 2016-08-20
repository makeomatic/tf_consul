# -*-Terraform-*-
#
# Creates consul+nomad instances in GCE.
#
# Region and zone should be passed to the module to configure where instances are created.
# Other provider attributes like credentials and account_file should be set outside, thus
# they will be inherited!
#

provider "google" {
    region = "${var.region}"
}

resource "google_compute_instance" "server" {
    count = "${var.servers}"
    name = "${var.tagName}-${count.index}"
    machine_type = "${var.machine_type}"
    zone = "${var.zone}"
    tags = [ "${var.tags}" ]

    can_ip_forward = true

    disk {
        image = "${data.null_data_source.gce.outputs.image}"
    }

    network_interface {
        network = "${var.network}"
        subnetwork = "${var.subnetwork}"
        access_config {
            nat_ip = "${var.nat_ip}"
        }
    }

    metadata = "${merge(
        data.null_data_source.metadata.outputs,
        map("user-data", data.template_cloudinit_config.default.rendered)
    )}"
}

# Write consul input.json configuration file
#
resource "null_resource" "input_file" {
    count = "${var.servers}"

    triggers {
        seed_address = "google_compute_instance.server.0.network_interface.0.address"
    }

    connection {
        host = "${
            element(
                google_compute_instance.server.*.network_interface.0.access_config.0.assigned_nat_ip,
                count.index
            )}"
        user = "${data.null_data_source.gce.outputs.user}"
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
        seed_address = "${element(google_compute_instance.server.*.network_interface.0.address, 0)}"
        servers = "${var.servers}"
        advertise_ipnum = "${var.advertise_ipnum}"

        # Consul specific
        consul_image = "${var.consul_image}"
        args = "${var.args}"
        dns_port = "${var.dns_port}"

        # Nomad specfic
        nomad_enabled = "${var.nomad_enabled}"
        nomad_image = "${var.nomad_image}"
        nomad_region = "${var.nomad_region}"
        nomad_datacenter = "${var.nomad_datacenter}"
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
        nomad-conf-content = "${file("${path.module}/../templates/nomad.conf.hcl.tmpl")}"
    }
}
