
variable "zone" {
    # Default is a computed value
    description = "Zone where machine is created."
    default = ""
}

variable "region" {
    description = "Region where machine is created."
    default = "europe-west1"
}

variable "machine_type" {
    description = "Default gce machine type."
    default = "n1-standard-1"
}

variable "instance_image" {
    description = "Default gce image used for instance creation."
    default = ""
}

variable "tags" {
    description = "List of tags to assign to an instance."
    default = []
}

variable "advertise_ipnum" {
    # We publish docker containers on the first avialable ip address (address of private NIC).
    description = "Use ip address of the first interface to advertise a docker container."
    default = "1"
}

variable "network" {
    description = "Name of network to use."
    default = "default"
}

variable "subnetwork" {
    description = "Name of subnetwork to use."
    default = ""
}

variable "nat_ip" {
    description = "Ephemeral address value if not given chosen automatically."
    default = ""
}

variable "metadata" {
    description = "Metadata key/value pairs to make available from within the instance."
    default = {}
}

variable "can_ip_forward" {
    description = "Whether to allow sending and receiving of packets with non-matching source or destination IPs."
    default = false
}

variable "platform" {
    description = "Platform (OS) used for the new instance."
    default = "ubuntu"
}

# Use this instead of passing sshKeys directly via metadata.
variable "sshKeys" {
    description = "List of ssh keys (user:pubkey items) to enable on machine along with the default user."
    default = []
}

variable "pubkey_path" {
    description = "Path to public key file."
    default = "~/.ssh/google_compute_engine.pub"
}

variable "key_path" {
    description = "Path to private key file."
    default = "~/.ssh/google_compute_engine"
}

variable "user" {
    description = "Default user uded for instance access."
    default = ""
}

variable "user_map" {
    default = {
        ubuntu  = "ubuntu"
    }
}

variable "image_map" {
    description = "Default image map, specifies what image to use for a particular OS."
    default = {
        ubuntu = "ubuntu-1604-xenial-v20160815"
    }
}

variable "metadata" {
    description = "Metadata passed to an instance upon creation."
    default = {}
}

variable "cross_zone_distribution" {
    description = "Flag specifies whether to distribute instance across availability zones."
    default = true
}

variable "available_zones" {
    description = "Zones available in GCE region."
    default = {
        us-west1 = "us-west1-a us-west1-b"
        us-central1 = "us-central1-a us-central1-b us-central1-c us-central1-f"
        us-east1 = "us-east1-b us-east1-c us-east1-d"
        europe-west1 = "europe-west1-b europe-west1-c europe-west1-d"
        asia-east1 = "asia-east1-a asia-east1-b asia-east1-c"
    }
}

# Gce defaults
data "null_data_source" "gce" {
    inputs {
        image  = "${coalesce(var.instance_image,  "${lookup(var.image_map, "${var.platform}")}")}"
        user = "${coalesce(var.user, "${lookup(var.user_map, var.platform)}")}"
        region_zones = "${lookup(var.available_zones, var.region)}"
    }
}

# Metadata helper used to calculate sshKeys
data "null_data_source" "metadata-default" {
    inputs {
        sshKeys = "${join("\n",
            distinct(
            concat(
                list("${data.null_data_source.gce.outputs.user}:${replace(file(var.pubkey_path), "/\n$/", "")}"),
                var.sshKeys
            ))
        )}"
    }
}

# Compound metadata
data "null_data_source" "metadata" {
    inputs = "${merge(data.null_data_source.metadata-default.outputs, var.metadata)}"
}
