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
    }

    metadata = "${merge(
        data.null_data_source.metadata.outputs,
        map()
    )}"
        # map("user-data", data.template_file.user-data.rendered)

}

# Compound cloud-init config
#
data "template_cloudinit_config" "default" {
  gzip          = true
  base64_encode = true

  part {
    filename = "include-list.cc"
    content_type = "text/x-include-url"
    content      = "${file("${path.module}/../include-list.cc")}"
  }

  # part {
  #   filename = "01.start-consul.sh"
  #   content_type = "text/x-shellscript"
  #   content      = "${data.template_file.start-consul.rendered}"
  # }

  # part {
  #   filename = "02.start-nomad.sh"
  #   content_type = "text/x-shellscript"
  #   content      = "${data.template_file.start-nomad.rendered}"
  # }

  # part {
  #   content_type = "text/cloud-config"
  #   content      = "${data.template_file.user-data.rendered}"
  # }
}


# # User-Data template
# #
# data "template_file" "user-data" {
#     template = "${file("${path.module}/../templates/user-data.cc.tmpl")}"
#     vars {
#         nomad_conf_content = "${base64encode(data.template_file.nomad-conf.rendered)}"
#     }
# }


# # When starting consul default -bootstrap-expect and -join options are substitued,
# # mind that args do override the behavior (ex. if you might want to join an
# # existing cluster).
# #
# data "template_file" "start-consul" {
#     template = "${file("${path.module}/../templates/start-consul.sh.tmpl")}"
#     vars {
#         servers = "${var.servers}"
#         image = "${var.image}"
#         args  = "${var.args}"
#         dns_port = "${var.dns_port}"
#         advertise_interface = "${var.advertise_interface}"
#         seed_address = "${google_compute_instance.server.0.network_interface.0.address}"
#     }
# }

# # This nomad setup doesn't support args overriding.
# #
# data "template_file" "start-nomad" {
#     template = "${file("${path.module}/../templates/start-nomad.sh.tmpl")}"
#     vars {
#         image = "${var.nomad_image}"
#         advertise_interface = "${var.advertise_interface}"
#     }
# }


# # Nomad config template
# #
# data "template_file" "nomad-conf" {
#     template = "${file("${path.module}/../templates/nomad.conf.tmpl")}"
#     vars {
#         servers = "${var.servers}"
#         region = "${var.nomad_region}"
#         datacenter = "${var.nomad_datacenter}"
#         seed_address = "${google_compute_instance.server.0.network_interface.0.address}"
#     }
# }


