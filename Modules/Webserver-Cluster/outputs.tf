output "asg_name" {
  value       = aws_autoscaling_group.asg.name
  description = "The name of the Auto Scaling Group"
}

output "instance_security_group_id" {
    value = aws_security_group.webapp_https_inbound_sg_private.id
}