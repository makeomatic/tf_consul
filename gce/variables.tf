variable "servers" {
    default = "3"
    description = "The number of Consul servers to launch."
}

variable "nomad" {
    description = "Specifies whether to bootstrap nomad along with consul."
    default = true
}

variable "join_address" {
    description = "If address is given we don't bootstrap a new cluster, but rather join to the existing one."
    default = ""
}

variable "image" {
    description = "Docker container used for consul server."
    default = "gliderlabs/consul-server"
}

variable "nomad_image" {
    description = "Specifies nomad container to use."
    default = "makeomatic/nomad"
}

variable "args" {
    description = "Default arguments passed to consul."
    default = ""
}

variable "tagName" {
    default = "consul"
    description = "AWS consul instance name tag."
}

variable "dns_port" {
    description = "Consul dns_port to bind to."
    default = 8600
}
