output "bastion_host_dns_name" {
  value       = aws_instance.bastion.public_dns
  description = "external DNS name of bastion host"
}