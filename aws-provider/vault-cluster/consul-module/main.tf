resource "aws_vpc" "VaultCluster_VPC" {
  cidr_block = var.vpc_cidr_block
  
  tags = {
    Name = "VaultCluster_VPC"
  }
}

resource "aws_security_group" "consul_SG" {
  name = "consul_SG"
  vpc_id = aws_vpc.VaultCluster_VPC.id

  ingress {
    cidr_blocks = [var.vpc_cidr_block]
    description = "Consul Server RPC address"
    from_port = 8300
    protocol = "tcp"
    to_port = 8300
  } 

  ingress {
    cidr_blocks = [var.vpc_cidr_block]
    description = ""
    from_port = 8301
    to_port = 8301
    protocol = "tcp"
  }

  ingress {
    cidr_blocks = [var.vpc_cidr_block]
    description = "Consul The Serf LAN port"
    from_port = 8301
    to_port = 8301
    protocol = "udp"
  }
}

resource "aws_launch_configuration" "consul_LC" {
  name_prefix = "consul-server-"
  image_id = var.image-id
  instance_type = var.instance-type
  user_data = file(consul-config.sh)
  security_groups = [aws_security_group.consul_SG.id]

  lifecycle {
    create_before_destroy = true
  }

}