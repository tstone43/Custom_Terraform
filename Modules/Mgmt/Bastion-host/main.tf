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

resource "aws_instance" "bastion" {
  ami = data.aws_ami.centos.id
  instance_type = "t2.micro"
  subnet_id = element(var.subnets,0)
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.bastion_ssh_sg.id}"]
  key_name = var.key_name
  tags = {
    "Name" = "${var.environment}-bastion"
  }
}

resource "aws_eip" "bastion"{
  instance = aws_instance.bastion.id
  vpc = true
}

resource "aws_security_group" "bastion_ssh_sg" {
  name        = "bastion_ssh"
  description = "Allow SSH to Bastion host from approved ranges"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(var.local_public_ip)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = var.vpc_id

  tags = {
    Name = "${var.environment}-bastion-ssh"
  }
}