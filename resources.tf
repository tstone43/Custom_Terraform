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
  security_groups = ["${aws_security_group.webapp_https_inbound_sg_private}"]
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
  subnets = ["${aws_subnet.public.*.id}"]
  tags = "${merge(var.tags, map("Name", format("%s-alb", var.name)))}"
}

resource "aws_autoscaling_group" "asg" {
  name                 = "websvr-asg"
  launch_configuration = "${aws_launch_configuration.web-svr-launch.name}"
  vpc_zone_identifier = ["${split(",",var.private_subnets)}"]
  min_size             = 1
  max_size             = 2
  wait_for_elb_capacity = false
  force_delete          = true
  load_balancers = "${aws_alb.webapp_alb.name}"
  tags = ["${
    list (
      map("key", "Name", "value", "ddt_webapp_asg", "propagate_at_launch", true)
    )

  }"]

  lifecycle {
    create_before_destroy = true
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

  dimensions {
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

  dimensions {
    autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
  }

  alarm_description = "EC2 CPU Utilization"
  alarm_actions = ["${aws_autoscaling_policy.scale_down.arn}"]
}

# Reference is deep dive terraform folder 6
resource "aws_instance" "bastion" {
  ami = "${data.aws_ami.windows.id}"
  instance_type = "t2.micro"
  subnet_id = "${element(aws_subnet.public.*.subnet_id,0)}"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.bastion_rdp_sg.id}"]
  key_name = "${var.key_name}"
  tags = "${merge(var.tags, map("Name", format("%s-bastion", var.name)))}"
}

resource "aws_eip" "bastion"{
  instance = "${aws_instance.bastion.id}"
  vpc = true
}