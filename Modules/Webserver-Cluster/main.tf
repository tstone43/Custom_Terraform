terraform {
  required_version = ">= 0.12, < 0.13"
}

data "aws_ami" "windows" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Full-Base*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_launch_configuration" "web-svr-launch" {
  name_prefix   = "${var.cluster_name}-websvr"
  image_id      = data.aws_ami.windows.id
  instance_type = var.instance_type
  placement_tenancy = "default"
  key_name = var.key_name
  associate_public_ip_address = false
  security_groups = [
    "${aws_security_group.webapp_https_inbound_sg_private.id}",
    "${aws_security_group.private_rdp_sg.id}",  
  ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                 = "websvr-asg"
  launch_configuration = aws_launch_configuration.web-svr-launch.name
  vpc_zone_identifier = var.vpc_zone_identifier
  min_size             = var.min_size
  max_size             = var.max_size
  force_delete          = true
  target_group_arns = var.target_group_arns
  health_check_type = "ELB"
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key = "Name"
    value = "webapp_asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name = "${var.cluster_name}-asg_scale_up"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  count = var.enable_autoscaling ? 1 : 0  
  alarm_name = "${var.cluster_name}-high-asg-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "80"
  insufficient_data_actions = []

  dimensions = {
    autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
  }

  alarm_description = "EC2 CPU Utilization"
  alarm_actions = ["${aws_autoscaling_policy.scale_up.arn}"]
}

resource "aws_autoscaling_policy" "scale_down" {  
  name = "${var.cluster_name}-low-asg-cpu"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 600
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  count = var.enable_autoscaling ? 1 : 0  
  alarm_name = "${var.cluster_name}-low-asg-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = "5"
  metric_name = "CPUUtlizaiton"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "30"
  insufficient_data_actions = []

  dimensions = {
    autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
  }

  alarm_description = "EC2 CPU Utilization"
  alarm_actions = ["${aws_autoscaling_policy.scale_down.arn}"]
}

resource "aws_security_group" "private_rdp_sg" {
  name        = "private_rdp"
  description = "Allow RDP to hosts on private subnets from approved ranges"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["${var.network_address_space}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = var.vpc_id

  tags = {
    Name = "${var.cluster_name}-private-rdp"
  }
}

resource "aws_security_group" "webapp_https_inbound_sg_private" {
  name        = "${var.cluster_name}_webapp_https_inbound_private"
  description = "Allow HTTPS from Public to Private"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["${var.network_address_space}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = var.vpc_id

  tags = {
    "Name" = "${var.cluster_name}-web_https_inbound_private"
  }
}

