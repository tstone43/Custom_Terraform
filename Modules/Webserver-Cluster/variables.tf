# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "enable_autoscaling" {
  description = "If set to true, enable auto scaling"
  type        = bool
}

variable "network_address_space" {
  default = "172.16.0.0/16"
}

variable "key_name" {
  description = "SSH key used to connect to EC2 instances"
  type = string  
}

variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type        = string
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "target_group_arns" {
  description = "The ARNs of ELB target groups in which to register Instances"
  type        = list(string)
  default     = []
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 443
}

variable "min_size" {
    description = "minimum number of EC2 instances to deploy"
    type = number
}

variable "max_size" {
    description = "maximum number of EC2 instances to deploy"
    type = number
}

variable "vpc_id" {

}

variable "vpc_zone_identifier" {

}

