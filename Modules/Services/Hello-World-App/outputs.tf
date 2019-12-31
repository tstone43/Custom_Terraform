output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "The domain name of the load balancer"
}

output "asg_name" {
  value       = module.Webserver-Cluster.asg_name
  description = "The name of the Auto Scaling Group"
}

output "instance_security_group_id" {
  value       = module.Webserver-Cluster.instance_security_group_id
  description = "The ID of the EC2 Instance Security Group"
}

output "bastion_host_dns_name" {
  value       = module.bastion_host.bastion_host_dns_name
  description = "public DNS name for Bastion host"
}