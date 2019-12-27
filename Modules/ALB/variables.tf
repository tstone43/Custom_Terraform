variable "internal_alb" {
  default = false
}

variable "alb_name" {
  description = "Either prod, dev, qa, or stage"
  type = string  
}

variable "alb_listener_port" {
  default = "443"
}

variable "alb_listener_protocol" {
  default = "HTTPS"
}

variable "vpc_id" {

}

variable "subnets" {
  description = "public subnets will be passed through"
}
