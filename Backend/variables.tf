variable "aws_access_key" {
  description = "key used to log into AWS"
  type = string
}

variable "aws_secret_key" {
  description = "secret used to log into AWS"
  type = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket. Must be globally unique."
  type        = string
  default     = "thomcstone_tf_state"
}

variable "table_name" {
  description = "The name of the DynamoDB table. Must be unique in this AWS account."
  type        = string
  default     = "thomcstone-tf-locks"
}