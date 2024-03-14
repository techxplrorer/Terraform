#Remote state configuration inside terraform block
terraform {
    # backend "s3" {
    #   bucket = "xplrorer-s3-bucket"
    #   key    = "xplrorer/terraform/remote/s3/terraform.tfstate"
    #   region = "us-east-1"
    #   dynamodb_table = "terraform-lock"
    #   encrypt = true
    #   }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

