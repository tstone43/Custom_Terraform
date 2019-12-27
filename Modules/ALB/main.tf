terraform {
  required_version = ">= 0.12, < 0.13"
}

resource "aws_alb" "webapp_alb" {
  name = var.alb_name
  internal = var.internal_alb
  load_balancer_type = "application"
  security_groups = ["${aws_security_group.webapp_https_inbound_sg.id}"]  
  subnets = var.subnets
  tags = {
    "Name" = "${var.alb_name}-alb"
  }
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.webapp_alb.arn
  port = var.alb_listener_port
  protocol = var.alb_listener_protocol
  certificate_arn = aws_iam_server_certificate.stonezone_cert.arn

  default_action {
    type = "fixed-response"

    fixed_response {
        content_type = "text/plain"
        message_body = "404: page not found"
        status_code = 404
    }
  }
}

resource "aws_iam_server_certificate" "stonezone_cert" {
  name_prefix = "stonezone-cert"
  certificate_body = file("${path.module}/cert.pem")
  private_key = file("${path.module}/key.pem")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "webapp_https_inbound_sg" {
  name        = "${var.alb_name}_webapp_https_inbound"
  description = "Allow HTTPS from Anywhere"

  ingress {
    from_port   = local.https_port
    to_port     = local.https_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }

  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = local.all_ips
  }

  vpc_id = var.vpc_id

  tags = {
    "Name" = "${var.alb_name}-web_https_inbound"
  }
}

locals {
    https_port = 443
    any_port = 0
    any_protocol = "-1"
    tcp_protocol = "tcp"
    all_ips = ["0.0.0.0/0"]
}



