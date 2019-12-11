# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the database's remote state"
  type        = string
  default = "thomcstone_tf_state"
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
  type        = string
  default = "Live/Stage/Services/Hello-world-app"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

#variable "server_text" {
  #description = "The text the web server should return"
  #default     = "Hello, World"
  #type        = string
#}

variable "environment" {
  description = "The name of the environment we're deploying to"
  type        = string
  default     = "stage"
}

variable "key_name" {
  description = "authentication key for RDP"
  type = string
}

variable "aws_access_key" {
  description = "key used to log into AWS"
  type = string
}

variable "aws_secret_key" {
  description = "secret used to log into AWS"
  type = string
}
