
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
    default = "ubuntu-1604-xenial-v20160815"
}

variable "tags" {
    description = "List of tags to assign to an instance."
    default = []
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
