provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-west-1"
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source = ".\\Modules\\VPC"
  name = "${var.environment_tag}"
  cidr = "${var.network_address_space}"
  azs = "${slice(data.aws_availability_zones.available.names,0,var.subnet_count)}"
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
  name_prefix   = "${var.environment_tag}-websvr"
  image_id      = "${data.aws_ami.windows.id}"
  instance_type = "t2.micro"
  placement_tenancy = "default"
  key_name = "${var.key_name}"
  associate_public_ip_address = false
  security_groups = ["${aws_security_group.webapp_https_inbound_sg_private.id}"]
  lifecycle {
    create_before_destroy = true
  }
}
# reference is https://medium.com/cognitoiq/terraform-and-aws-application-load-balancers-62a6f8592bcf
resource "aws_alb" "webapp_alb" {
  name = "${var.environment_tag}-alb"
  internal = "${var.internal_alb}"
  load_balancer_type = "application"
  security_groups = ["${aws_security_group.webapp_https_inbound_sg.id}"]  
  subnets = flatten([module.vpc.public_subnets])
  tags = {
    "Name" = "${var.environment_tag}-alb"
  }
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = "${aws_alb.webapp_alb.arn}"
  port = "${var.alb_listener_port}"
  protocol = "${var.alb_listener_protocol}"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target.arn}"
    type = "forward"
  }
}

resource "aws_alb_listener_rule" "listener_rule" {
  depends_on = ["aws_alb_target_group.alb_target_group"]
  listener_arn = "${aws_alb_listener.alb_listener.arn}"
  
  action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.alb_target_group.id}"
  }
  
  condition {
    field = "path-pattern"
    values = ["*"]
  }
}

resource "aws_alb_target_group" "alb_target_group" {
  name = "${var.environment_tag}-target-group"
  port = "${var.alb_listener_port}"
  protocol = "${var.alb_listener_protocol}"
  vpc_id = module.vpc.vpc_id
  tags {
    name =
  }
}

# In config below load_balancers has to use target group ARN
resource "aws_autoscaling_group" "asg" {
  name                 = "websvr-asg"
  launch_configuration = "${aws_launch_configuration.web-svr-launch.name}"
  vpc_zone_identifier = flatten(module.vpc.private_subnets)
  min_size             = 1
  max_size             = 2
  force_delete          = true
  load_balancers = "${aws_alb.webapp_alb.name}"
  tag {
    key = "Name"
    value = "webapp_asg"
    propagate_at_launch = true
  }
} 
  
resource "aws_autoscaling_policy" "scale_up" {
  name = "${var.environment_tag}-asg_scale_up"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name = "${var.environment_tag}-high-asg-cpu"
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
  name = "${var.environment_tag}-low-asg-cpu"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 600
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name = "${var.environment_tag}-low-asg-cpu"
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

# Reference is deep dive terraform folder 6
resource "aws_instance" "bastion" {
  ami = "${data.aws_ami.windows.id}"
  instance_type = "t2.micro"
  #subnet_id = "${element(module.vpc.public_subnets, 0)}"
  subnet_id = "${var.first_public_subnet}[0]"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.bastion_rdp_sg.id}"]
  key_name = "${var.key_name}"
  tags = {
    "Name" = "${var.environment_tag}-bastion"
  }
}

resource "aws_eip" "bastion"{
  instance = "${aws_instance.bastion.id}"
  vpc = true
}