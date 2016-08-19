variable "servers" {
    default = "3"
    description = "The number of Consul servers to launch."
}

variable "nomad" {
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
    default = "gliderlabs/consul-server"
}

variable "nomad_image" {
    description = "Specifies nomad container to use."
    default = "makeomatic/nomad"
}

variable "args" {
    description = "Arguments passed to consul (override default initialization logic)."
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
