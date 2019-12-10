provider "aws" {
    region = "us-west-1"
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"

  # Allow any 2.x version of the AWS provider
  version = "~> 2.0"
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "thomcstone_tf_state"

    lifecycle {
        prevent_destroy = true
    }

    versioning {
        enabled = true
    }

    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }
}

resource "aws_dynamodb_table" "terraform_locks" {
    name = "thomcstone-tf-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}

terraform {
    backend "s3" {
        bucket = "thomcstone_tf_state"
        key = "global/s3/terraform.tfstate"
        region = "us-west-1"
        dynamodb_table = "thomcstone-tf-locks"
        encrypt = true 
    }
}