resource "aws_security_group" "consul" {
    name = "${var.security_group}"
    description = "Consul internal traffic + maintenance."
    vpc_id = "${var.vpc_id}"

    // These are for maintenance
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    // This is for outbound internet access
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    /* ----- Consul server ports ----- */
    # Server RPC port
    ingress {
        from_port = 8300
        to_port = 8300
        protocol = "tcp"
        self = true
    }

    # Serf LAN and WAN (8301 and 8302 respectively)
    ingress {
        from_port = 8301
        to_port = 8302
        protocol = "tcp"
        self = true
    }
    ingress {
        from_port = 8301
        to_port = 8302
        protocol = "udp"
        self = true
    }

    # Consul client RPC
    ingress {
        from_port = 8400
        to_port = 8400
        protocol = "tcp"
        self = true
    }

    # Consul HTTP API
    ingress {
        from_port = 8500
        to_port = 8500
        protocol = "tcp"
        self = true
        security_groups = ["${var.AllowAPI_access_SGids}"]
    }

    # Consul DNS ports
    ingress {
        from_port = "${var.consul_dnsport}"
        to_port = "${var.consul_dnsport}"
        protocol = "tcp"
        self = true
        security_groups = ["${var.AllowAPI_access_SGids}"]
    }
    ingress {
        from_port = "${var.consul_dnsport}"
        to_port = "${var.consul_dnsport}"
        protocol = "tcp"
        self = true
        security_groups = ["${var.AllowAPI_access_SGids}"]
    }
}
