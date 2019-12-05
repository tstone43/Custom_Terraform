output "alb_security_group_id" {
  value       = aws_security_group.webapp_https_inbound_sg.id
  description = "The ALB Security Group ID"
}

output "alb_dns_name" {
  value       = aws_alb.webapp_alb.dns_name
  description = "The domain name of the load balancer"
}

output "alb_http_listener_arn" {
  value       = aws_alb_listener.alb_listener.arn
  description = "The ARN of the HTTP listener"
}
