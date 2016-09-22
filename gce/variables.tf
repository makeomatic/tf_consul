variable "servers" {
    default = "3"
    description = "The number of Consul servers to launch."
}

variable "tagName" {
    default = "consul"
    description = "GCE consul instance name tag."
}

variable "nomad_enabled" {
    description = "Specifies whether to bootstrap nomad along with consul."
    default = true
}

variable "nomad_region" {
    description = "Specifies nomad region."
    default = "global"
}

variable "nomad_datacenter" {
    description = "Specifies nomad datacenter."
    default = "dc1"
}

variable "consul_image" {
    description = "Docker container used for consul server."
    default = "stackfeed/consul:0.6-server"
}

variable "nomad_image" {
    description = "Specifies nomad container to use."
    default = "makeomatic/nomad:0.4"
}

variable "consul_args" {
    description = "Arguments passed to consul (override default initialization logic)."
    default = ""
}

variable "consul_dnsport" {
    description = "Consul dns port to bind to."
    default = 8600
}
