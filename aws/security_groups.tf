
# Consul security group
#
resource "aws_security_group" "consul" {
    name = "${var.security_group}"
    description = "Consul internal traffic + maintenance."
    vpc_id = "${var.vpc_id}"

    tags = {
        Name = "${var.project_tag}"
    }

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
        security_groups = ["${var.SGAllow_ConsulAPInDNS}"]
    }

    # Consul DNS ports
    ingress {
        from_port = "${var.consul_dnsport}"
        to_port = "${var.consul_dnsport}"
        protocol = "tcp"
        self = true
        security_groups = ["${var.SGAllow_ConsulAPInDNS}"]
    }
    ingress {
        from_port = "${var.consul_dnsport}"
        to_port = "${var.consul_dnsport}"
        protocol = "tcp"
        self = true
        security_groups = ["${var.SGAllow_ConsulAPInDNS}"]
    }
}


## Nomad security group
#
resource "aws_security_group" "nomad" {
    name = "${var.nomad_sgname}"
    description = "Nomad security group."
    vpc_id = "${var.vpc_id}"

    tags = {
        Name = "${var.project_tag}"
    }

    # Nomad http server (applies to server+client)
    ingress {
        from_port = 4646
        to_port = 4646
        protocol = "tcp"
        self = true
        security_groups = ["${var.SGAllow_NomadAPI}"]
    }

    # Nomad RPC (Raft) (applies to server+client)
    ingress {
        from_port = 4647
        to_port = 4647
        protocol = "tcp"
        self = true
    }

    # Nomad serf gossip TCP+UDP (applies to server)
    ingress {
        from_port = 4648
        to_port = 4648
        protocol = "tcp"
        self = true
    }
    ingress {
        from_port = 4648
        to_port = 4648
        protocol = "udp"
        self = true
    }
}


## Swarm security group
#
resource "aws_security_group" "swarm" {
    name = "${var.swarm_sgname}"
    description = "Docker Swarm internal traffic + maintenance."
    vpc_id = "${var.vpc_id}"

    tags = {
        Name = "${var.project_tag}"
    }

    /* ----- Swarm manager ----- */
    // Swarm docker hub must have
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    // Swarm engine and manager access
    ingress {
        from_port = "${var.swarm_engineport}"
        to_port = "${var.swarm_engineport}"
        protocol = "tcp"
        self = true
    }
    ingress {
        from_port = "${var.swarm_managerport}"
        to_port = "${var.swarm_managerport}"
        protocol = "tcp"
        self = true
        security_groups = ["${var.SGAllow_SwarmAPI}"]
    }

    // Swarm engine and manager access (TLS)
    ingress {
        from_port = "${var.swarm_engineport + 1}"
        to_port = "${var.swarm_engineport + 1}"
        protocol = "tcp"
        self = true
    }
    ingress {
        from_port = "${var.swarm_managerport + 1}"
        to_port = "${var.swarm_managerport + 1}"
        protocol = "tcp"
        self = true
        security_groups = ["${var.SGAllow_SwarmAPI}"]
    }

    /* ----- Custom, cross-host container networks ----- */
    // Allows for discovering other container networks.
    ingress {
        from_port = 7946
        to_port = 7946
        protocol = "tcp"
        self = true
    }
    ingress {
        from_port = 7946
        to_port = 7946
        protocol = "udp"
        self = true
    }

    // Overlay network traffic
    ingress {
        from_port = 4789
        to_port = 4789
        protocol = "udp"
        self = true
    }
}
