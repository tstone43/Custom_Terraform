variable "name" {
  description = "Name to be used on all the resources as identifier"
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for the public subnets"
  default     = {}
}

variable "cidr" {
  description = "cidr block for VPC"
}

variable "azs" {
    default = []
}

variable "instance_tenancy" {
    default = "default"
}

variable "enable_dns_hostnames" {
    default = true
}

variable "enable_dns_support" {
    default = true
}

variable "enable_nat_gateway" {
    default = true
}

variable "map_public_ip_on_launch" {
    default = true
}



