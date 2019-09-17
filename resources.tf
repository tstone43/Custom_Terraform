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
  name_prefix   = "websvr-"
  image_id      = "${data.aws_ami.windows.id}"
  instance_type = "t2.micro"
  placement_tenancy = "default"
  

  lifecycle {
    create_before_destroy = true
  }
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
# Was looking a deep dive terraform folder 6 and need to finish this configuration
resource "aws_instance" "bastion" {
  ami = "${data.aws_ami.windows.id}"
  instance_type = "t2.micro"
  subnet_id = "${element(aws_subnet.public.*.subnet_id,0)}"
  associate_public_ip_address = true

}