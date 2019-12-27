terraform {
  required_version = ">= 0.12, < 0.13"
}

provider "aws" {
  region = "us-west-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  # Allow any 2.x version of the AWS provider
  version = "~> 2.0"
}

module "hello_world_app" {

  source = "../../../../Modules/Services/Hello-World-App"

  environment            = var.environment
  key_name               = var.key_name
  private_key = var.private_key_path

  instance_type      = "t2.micro"
  min_size           = 1
  max_size           = 2
  enable_autoscaling = true
}

# Partial backend configuration.  You will need a backend.hcl file to complete config.
terraform {
  backend "s3" {
    key = "Live/Stage/Services/Hello-world-app/terraform.tfstate"
  }
}
