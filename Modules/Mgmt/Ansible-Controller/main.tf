terraform {
  required_version = ">= 0.12, < 0.13"
}

data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS ENA 1901*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
   owners = ["679593333241"]

}

resource "aws_instance" "ansible-controller" {
  ami = data.aws_ami.centos.id
  instance_type = "t2.micro"
  subnet_id = element(var.subnets,0)
  associate_public_ip_address = false
  vpc_security_group_ids = ["${aws_security_group.private_ssh_ansible.id}"]
  key_name = var.key_name
  user_data = file("${path.module}/install_ansible.sh")
  tags = {
    "Name" = "${var.environment}-ansible-controller"
  }
}

resource "aws_security_group" "private_ssh_ansible" {
  name        = "private_ssh_ansible"
  description = "Allow SSH to Ansible controller node from approved ranges"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
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