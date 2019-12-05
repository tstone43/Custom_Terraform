terraform {
  # Require any 0.12.x version of Terraform
  required_version = ">= 0.12, < 0.13"
}

data "aws_availability_zones" "available" {}

module "Webserver-Cluster" {
    source = "../../Webserver-Cluster"
    cluster_name = "hello-world-${var.environment}"
    instance_type = var.instance_type
    enable_autoscaling = var.enable_autoscaling
    key_name = var.key_name
    min_size = var.min_size
    max_size = var.max_size
    vpc_id = "${module.vpc.vpc_id}"
    vpc_zone_identifier = flatten(module.vpc.private_subnets)
    target_group_arns = [aws_lb_target_group.asg.arn]
}

module "vpc" {
    source = "../../VPC"
    cidr = var.network_address_space
    azs = "${slice(data.aws_availability_zones.available.names,0,var.subnet_count)}"
    name = var.environment
}

module "alb" {
    source = "../../ALB"
    alb_name = "hello-world-${var.environment}"
    vpc_id = "${module.vpc.vpc_id}"
    subnets = flatten([module.vpc.public_subnets])
}

resource "aws_lb_target_group" "asg" {
    name = "hello-world-${var.environment}"
    port = var.server_port
    protocol = var.protocol
    vpc_id = module.vpc.vpc_id
    
    health_check {
        path = "/"
        protocol = var.protocol
        matcher = "200"
        interval = 15
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
    }

}

resource "aws_lb_listener_rule" "asg" {
    listener_arn = module.alb.alb_http_listener_arn
    priority = 100

    condition {
        field = "path-pattern"
        values = ["*"]
    }

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.asg.arn
    }
}

module "bastion_host" {
    source = "../../Mgmt/Bastion-host"
    vpc_id = "${module.vpc.vpc_id}"
    subnets = flatten([module.vpc.public_subnets])
    environment = var.environment
    key_name = var.key_name

}