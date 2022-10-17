resource "aws_vpc" "VaultCluster_VPC" {
  cidr_block = var.vpc_cidr_block
  
  tags = {
    Name = "VaultCluster_VPC"
  }
}

resource "aws_subnet" "consul-cluster-subnet" {
  vpc_id = aws_vpc.VaultCluster_VPC.id
  cidr_block = var.subnet-idr-block

  tags = {
    "Name" = "consul-cluster-subnet"
  }
}

resource "aws_security_group" "consul_SG" {
  name = "consul_SG"
  vpc_id = aws_vpc.VaultCluster_VPC.id

  ingress {
    cidr_blocks = [var.vpc_cidr_block]
    description = "Allows servers to handle incoming requests from other agents"
    from_port = 8300
    protocol = "tcp"
    to_port = 8300
    self = true
  } 

  ingress {
    cidr_blocks = [var.vpc_cidr_block]
    description = "Allows gossip in the LAN"
    from_port = 8301
    to_port = 8301
    protocol = "tcp"
    self = true
  }

  ingress {
    cidr_blocks = [var.vpc_cidr_block]
    description = "Allows gossip in the LAN"
    from_port = 8301
    to_port = 8301
    protocol = "udp"
    self = true
  }

  ingress {
    cidr_blocks = [var.vpc_cidr_block]
    description = "Allows servers to gossip over the WAN, to other servers"
    from_port = 8302
    to_port = 8302
    protocol = "tcp"
    self = true
  }

  ingress {
    cidr_blocks = [var.vpc_cidr_block]
    description = "Allows servers to gossip over the WAN, to other servers"
    from_port = 8302
    to_port = 8302
    protocol = "udp"
    self = true
  }

  ingress {
    cidr_blocks = [var.vpc_cidr_block]
    description = "The DNS server"
    from_port = 8600
    to_port = 8600
    protocol = "tcp"
    self = true
  }

  ingress {
    cidr_blocks = [var.vpc_cidr_block]
    description = "The DNS server"
    from_port = 8600
    to_port = 8600
    protocol = "udp"
    self = true
  }

  ingress {
    cidr_blocks = [var.vpc_cidr_block]
    description = "The HTTP API"
    from_port = 8500
    to_port = 8500
    protocol = "tcp"
    self = true
  }
}

resource "aws_launch_template" "consul_LT" {
  name_prefix = "consul-server-"
  image_id = var.image-id
  instance_type = var.instance-type
  key_name = "consul_server_key"

  network_interfaces {
    associate_public_ip_address = true
  }

  vpc_security_groups_ids = [aws_security_group.consul_SG.id]

  lifecycle {
    create_before_destroy = true
  }

  user_data = filebase64(consul-config.sh)
}

resource "aws_autoscaling_group" "consul_server_ASG" {
  availabilty_zones = var.availability_zones
  desired_capacity = var.number_of_servers
  max_size = var.max_number_of_servers
  min_size = var.min_number_of_servers

  launch_template {
    id = aws_launch_template.consul_LT.id
    version = "$Lastest"
  }

}