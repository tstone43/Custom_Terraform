output "alb_dns_name" {
  value       = module.hello_world_app.alb_dns_name
  description = "The domain name of the load balancer"
}

output "bastion_host_dns_name" {
  value       = module.hello_world_app.bastion_host_dns_name
  description = "public DNS name for Bastion host"  
}

output "ansible_controller_dns_name" {
  value       = module.hello_world_app.ansible_controller_dns_name
  description = "public DNS name for Ansible controller host"
}
