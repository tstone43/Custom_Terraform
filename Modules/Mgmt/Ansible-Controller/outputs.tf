output "ansible_controller_dns_name" {
    value       = aws_instance.ansible-controller.public_dns
    description = "external DNS name of ansible controller"
}
