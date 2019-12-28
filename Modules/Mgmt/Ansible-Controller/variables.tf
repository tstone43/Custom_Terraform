variable "vpc_id" {

}

variable "subnets" {
  description = "Will to set to a public subnet"
}

variable "environment" {
  description = "The name of the environment we're deploying to"
  type        = string
}

variable "key_name" {
  description = "The name of the environment we're deploying to"
  type        = string
}

variable "cidr" {
  description = "This is used to allow CIDR in security groups"
}

variable "private_key" {
  description = "Used to SSH to Ansible controller"
}

variable "local_public_ip" {
  type        = string
}