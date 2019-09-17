provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-west-1"
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source = "./Modules/VPC"
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
  associate_public_ip_address = true
  lifecycle {
    create_before_destroy = true
  }
}
# reference is https://www.terraform.io/docs/providers/aws/r/lb.html and obviously not complete
resource "aws_alb" "webapp_alb" {
  name = "${var.environment_tag}-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = 
  subnets = 
}

resource "aws_autoscaling_group" "asg" {
  name                 = "websvr-asg"
  launch_configuration = "${aws_launch_configuration.web-svr-launch.name}"
  min_size             = 1
  max_size             = 2

  lifecycle {
    create_before_destroy = true
  }
}
# Reference is deep dive terraform folder 6
resource "aws_instance" "bastion" {
  ami = "${data.aws_ami.windows.id}"
  instance_type = "t2.micro"
  subnet_id = "${element(aws_subnet.public.*.subnet_id,0)}"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.bastion_rdp_sg.id}"]
  key_name = "${var.key_name}"
  tags = "${var.environment_tag}-bastion"
}

resource "aws_eip" "bastion"{
  instance = "${aws_instance.bastion.id}"
  vpc = true
}