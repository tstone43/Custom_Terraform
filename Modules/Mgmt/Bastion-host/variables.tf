variable "vpc_id" {

}

variable "subnets" {

}

variable "environment" {
  description = "The name of the environment we're deploying to"
  type        = string
}

variable "key_name" {
  description = "The name of the environment we're deploying to"
  type        = string
}