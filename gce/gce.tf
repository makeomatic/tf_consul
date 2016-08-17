
variable "credentials" {
    type = "string"
    description = "Path to google account credentials file (account json)."
}

variable "zone" {
    description = "The zone that the machine should be created in."
    default = "europe-west1-d"
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

variable "advertise_interface" {
    # By default we publish services on the GCE private interface.
    description = "Use ip address of the interface to advertise a docker container."
    default = "eth0"
}

variable "network_interface" {
    description = "Networks to attach to the instance."
    default = {
        network = "default"
    }
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
    description = "Path to pub"
    default = "default_value"
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

data "null_data_source" "gce" {
    inputs = {
        image  = "${coalesce(var.instance_image,  "${lookup(var.image_map, "${var.platform}")}")}"
        user = "${coalesce(var.user, "${lookup(var.user_map, var.platform)}")}"
    }
}

# Metadata helper used to calculate sshKeys
data "null_data_source" "metadata-default" {
    inputs = {
        sshKeys = "${join("\n",
            distinct(
            concat(
                list("${var.user}:${var.pubkey_path}")
                var.sshKeys
            ))
        )}"
    }
}

# Compound metadata
data "null_data_source" "metadata" {
    inputs = "${merge(var.metadata-default, var.metadata)}"
}
