variable "servers" {
    default = "3"
    description = "The number of Consul servers to launch."
}

variable "image" {
    description = "Docker container used for consul server."
    default = "gliderlabs/consul-server"
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

variable "AllowAPI_access_SGids" {
    description = "Allow access to API and DNS."
    default = []
}
