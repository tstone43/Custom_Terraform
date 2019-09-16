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

resource "aws_autoscaling_group" "bar" {
  name                 = "websvr-asg"
  launch_configuration = "${aws_launch_configuration.web-svr-launch.name}"
  min_size             = 1
  max_size             = 2

  lifecycle {
    create_before_destroy = true
  }
}