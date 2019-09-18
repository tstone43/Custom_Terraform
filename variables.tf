variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "environment_tag" {}

variable "subnet_count" {
  default = 2
}

variable "network_address_space" {
  default = "172.16.0.0/16"
}

variable "internal_alb" {
  default = false
}

variable "alb_listener_port" {}

variable "alb_listener_protocol" {}