# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "environment" {
  description = "The name of the environment we're deploying to"
  type        = string
}

variable "enable_autoscaling" {
  description = "If set to true, enable auto scaling"
  type        = bool
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type        = string
  default     = "t2.micro"
}

variable "network_address_space" {
  default = "172.16.0.0/16"
}

variable "subnet_count" {
  default = 2
}

variable "server_port" {
  description = "The port the server will use for HTTPS requests"
  type        = number
  default     = 443
}

variable "protocol" {
    description = "The protocol the server will use for requests"
    type = string
    default = "HTTPS"
}

variable "key_name" {
  description = "authentication key for RDP"
  type = string
}

variable "min_size" {
    description = "minimum number of EC2 instances to deploy"
    type = number
}

variable "max_size" {
    description = "maximum number of EC2 instances to deploy"
    type = number
}