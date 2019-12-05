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

# Used to convert the public subnets to string
#locals {
  #str_public_subnets = flatten(module.vpc.public_subnets)
#}

# Reference is deep dive terraform folder 6
resource "aws_instance" "bastion" {
  ami = "${data.aws_ami.windows.id}"
  instance_type = "t2.micro"
  subnet_id = "${element(var.subnets,0)}"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.bastion_rdp_sg.id}"]
  key_name = "${var.key_name}"
  tags = {
    "Name" = "${var.environment}-bastion"
  }
}

resource "aws_eip" "bastion"{
  instance = "${aws_instance.bastion.id}"
  vpc = true
}

resource "aws_security_group" "bastion_rdp_sg" {
  name        = "bastion_rdp"
  description = "Allow RDP to Bastion host from approved ranges"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = var.vpc_id

  tags = {
    Name = "${var.environment}-bastion-rdp"
  }
}