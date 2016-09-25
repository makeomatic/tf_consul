variable "servers" {
    default = "3"
    description = "The number of Consul servers to launch."
}

variable "tagName" {
    default = "consul"
    description = "AWS consul instance name tag."
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

variable "swarm_enabled" {
    description = "Install swarm manager server along with consul."
    default = false
}

variable "swarm_image" {
    description = "Docker swarm container image."
    default = "swarm"
}

variable "swarm_managerport" {
    description = "Specifies swarm manager port."
    default = 3375
}

variable "swarm_engineport" {
    description = "Specifies swarm client node port."
    default = 2375
}


variable "nomad_sgname" {
    description = "Specifies nomad security group name."
    default = "nomad"
}

variable "swarm_sgname" {
    description = "Specifies swarm security group name."
    default = "swarm"
}

variable "SGAllow_ConsulAPInDNS" {
    description = "List of security group IDs allowed to access consul DNS and API."
    default = []
}

variable "SGAllow_NomadAPI" {
    description = "List of security group IDs allowed to access nomad Rest API."
    default = []
}

variable "SGAllow_SwarmAPI" {
    description = "List of security group IDs allowed to access swarm Rest API."
    default = []
}
