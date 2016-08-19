
#
# ======= AWS compute varaiables
#

variable "platform" {
    default = "ecs"
    description = "Sets which platform to use (by default ECS Optimized AMI)."
}

variable "region" {
    description = "The AWS region to create things in"
    default = "eu-central-1"
}

variable "region_aznumber" {
    default = {
        us-east-1 = 4
        us-west-1 = 2
        us-west-2 = 3
        eu-west-1 = 3
        eu-central-1 = 2
        ap-southeast-1 = 2
        ap-southeast-2 = 2
        ap-northeast-1 = 2
        sa-east-1 = 3
    }
}

variable "availability_zone" {
    # Also there's data.aws_availability_zones.available.names which can be used.
    description = "Specifies availability zone to use."
    default = ""
}

variable "cross_zone_distribution" {
    description = "Flag specifies whether to distribute instance across availability zones."
    default = true
}

variable "user" {
    description = "Default aws user (if not given it's calculated based on platform)."
    default = ""
}

variable "user_map" {
    default = {
        ecs = "ec2-user"
        ubuntu  = "ubuntu"
    }
}

variable "ami" {
    description = "Default ami used."
    default = ""
}

variable "ami_map" {
    description = "AWS AMI Id, for the specific region."
    default = {
        # Get update ecs ami id here:
        # http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
        us-east-1-ecs = "ami-55870742"
        us-west-1-ecs = "ami-07713767"
        us-west-2-ecs = "ami-241bd844"
        eu-west-1-ecs = "ami-c74127b4"
        eu-central-1-ecs = "ami-3b54be54"
        us-east-1-ubuntu = "ami-cf68e0d8"
        us-west-1-ubuntu = "ami-e59bda85"
        us-west-2-ubuntu = "ami-191fd379"
        eu-west-1-ubuntu = "ami-1967056a"
        eu-central-1-ubuntu = "ami-cbee1aa4"
    }
}

variable "instance_type" {
    default = "t2.micro"
    description = "AWS Instance type"
}

variable "security_group" {
    description = "Default security name which is created by compute module user."
    default = ""
}

# !! Names or IDs it should be passed properly to resources such as aws_instance
# (specifically security_groups or vpc_security_group_ids must be chosen).
variable "security_groups" {
    description = "A list of security group names or IDs to associate with an instance."
    default = []
}

variable "default-vpc" {
    description = "Set to false to operate on non-default VPC."
    default = true
}

variable "vpc_id" {
    description = "Defines a VPC id where actions are taken."
    default = ""
}

variable "subnet_id" {
    description = "Can be set to provide a subnet_id where instance is provision."
    default = ""
}

variable "subnet_ids" {
    description = "A ordered list of subnet_ids to choose from when creating instance in non-default VPC."
    default = [""]
}

variable "key_name" {
    type = "string"
    description = "SSH key pair name in your AWS account for AWS instances."
}

variable "key_path" {
    type = "string"
    description = "Path to the private key used for ssh connection."
}

variable "advertise_ipnum" {
    # We publish docker containers on the first avialable ip address (address of private NIC).
    description = "Use ip address of the first interface to advertise a docker container."
    default = "1"
}

variable "volume_size_map" {
    description = "Default available size for specific volume."
    default = {
        gp2 = 1
        io1 = 4
        st1 = 500
        sc1 = 500
    }
}

#
# ======= AWS compute data sources
#

data "aws_availability_zones" "available" {}

data "null_data_source" "aws" {
    inputs = {
        ami  = "${coalesce(var.ami,  "${lookup(var.ami_map, "${var.region}-${var.platform}")}")}"
        user = "${coalesce(var.user, "${lookup(var.user_map, var.platform)}")}"
    }
}

#
# ======= AWS compute outputs
#

output "advertise_interface" { value = "${var.advertise_interface}" }
output "instance_type" { value = "${var.instance_type}" }

output "key_name" { value = "${var.key_name}" }
output "key_path" { value = "${var.key_path}" }

output "cross_zone_distribution" { value = "${var.cross_zone_distribution}" }
output "region" { value = "${var.region}" }
output "availability_zone" { value = "${var.availability_zone}" }

output "default-vpc" { value = "${var.default-vpc}" }
output "vpc_id" { value = "${var.vpc_id}" }
output "subnet_id" { value = "${var.subnet_id}" }
output "security_group" { value = "${var.security_group}" }
output "volume_size_map" { value = "${var.volume_size_map}" }

output "ami" { value = "${data.null_data_source.aws.outputs["ami"]}" }
output "user" { value = "${data.null_data_source.aws.outputs["user"]}" }
