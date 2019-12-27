variable "vpc_id" {

}

variable "subnets" {
  description = "This will be set to a public subnet"
}

variable "environment" {
  description = "The name of the environment we're deploying to"
  type        = string
}

variable "key_name" {
  description = "key pair used to connect to host"
  type        = string
}