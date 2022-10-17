output "number_of_server" {
  value = aws_autoscaling_group.consul_server_ASG.desired_capacity
  description = "This is the desired number of consul server in the cluster"
}

output "launch_template_name" {
  value = aws_launch_template.consul_LT.name
  description = "This is the name of the launch template used to bootstrap the instances in the cluster."
}

output "security_group_id" {
  value = aws_security_group.consul_SG.id
  descrdescription = "This the id of the security group that governs ingress and egress for the cluster instances"  
}