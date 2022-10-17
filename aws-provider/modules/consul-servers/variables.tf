variable "region" {}
variable "image-id" {
  description = "The id of the AMI to be used inthe instances"
  type = string
}

variable "instance-type" {
  description = "The type of EC2 instances to be used in the cluster."
  type = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the cluster will be deployed."
  type = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block used in the VPC"
}

variable "number_of_servers" {
  description = "The number of server nodes in the cluster"
  type = number
  default = 3
}

variable "max_number_of_servers" {
  description = "The maximum number of server in the cluster"
  type = number
  default = 3
}
variable "min_number_of_servers" {
  description = "The minimum number of server in the cluster."
  type = number
  default = 2
}