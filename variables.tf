variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "environment_tag" {
  type = "string"
  default = "test"
}

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

variable "key_name" {
  default = "tcs-kp"
}

variable "first_public_subnet" {
  type = "string"
  default = "module.vpc.public_subnets"
}
