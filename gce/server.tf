resource "google_compute_instance" "server" {
    count = "${var.servers}"
    name = "${var.tagName}-${count.index}"
    machine_type = "${var.machine_type}"
    zone = "${var.zone}"
    tags = [ "${var.tags}" ]

    disk {
        image = "${data.null_data_source.gce.outputs.image}"
    }

    network_interface "${var.network_interface}"

    metadata "${data.null_data_source.metadata.outputs}"
}
