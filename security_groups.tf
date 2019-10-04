# Items pasted here just to provide example
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

  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "terraform_bastion_rdp"
  }
}
# Left off here, need to think more about what security groups I actually need
resource "aws_security_group" "webapp_https_inbound_sg" {
  name        = "${var.environment_tag}_webapp_https_inbound"
  description = "Allow HTTPS from Anywhere"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = module.vpc.vpc_id

  tags = {
    "Name" = "${var.environment_tag}-web_https_inbound"
  }
}

resource "aws_security_group" "webapp_https_inbound_sg_private" {
  name        = "${var.environment_tag}_webapp_https_inbound_private"
  description = "Allow HTTPS from Public to Private"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.network_address_space}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = module.vpc.vpc_id

  tags = {
    "Name" = "${var.environment_tag}-web_https_inbound_private"
  }
}

resource "aws_security_group" "webapp_outbound_sg" {
  name        = "${var.environment_tag}_outbound"
  description = "Allow outbound connections"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = module.vpc.vpc_id

  tags = {
    "Name" = "${var.environment_tag}-outbound"
  }
}

#resource "aws_security_group" "rds_sg" {
  #name        = "demo_rds_inbound"
  #description = "Allow inbound from web tier"
  #vpc_id      = "${data.terraform_remote_state.networking.vpc_id}"

  #tags {
    #Name = "demo_rds_inbound"
  #}

  // allows traffic from the SG itself
  #ingress {
    #from_port = 0
    #to_port   = 0
    #protocol  = "-1"
    #self      = true
  #}

  // allow traffic for TCP 3306
  #ingress {
    #from_port       = 3306
    #to_port         = 3306
    #protocol        = "tcp"
    #security_groups = ["${aws_security_group.webapp_http_inbound_sg.id}"]
  #}

  // outbound internet access
  #egress {
    #from_port   = 0
    #to_port     = 0
    #protocol    = "-1"
    #cidr_blocks = ["0.0.0.0/0"]
  #}
#}