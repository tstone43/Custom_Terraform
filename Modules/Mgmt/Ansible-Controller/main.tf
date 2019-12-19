terraform {
  required_version = ">= 0.12, < 0.13"
}

data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS 7.7.1908 x86_64 with cloud-init*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

resource "aws_instance" "ansible-controller" {
  ami = "${data.aws_ami.centos.id}"
  instance_type = "t2.micro"
  subnet_id = "${element(var.subnets,0)}"
  associate_public_ip_address = false
  vpc_security_group_ids = ["${aws_security_group.private_ssh.id}"]
  key_name = "${var.key_name}"
  tags = {
    "Name" = "${var.environment}-ansible-controller"
  }
}

resource "aws_security_group" "private_ssh" {
  name        = "private_ssh"
  description = "Allow RDP to Bastion host from approved ranges"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = var.vpc_id

  tags = {
    Name = "${var.environment}-ansible-controller"
  }
}