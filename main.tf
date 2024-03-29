terraform {
  backend "s3" {
    profile = ""
    encrypt = true
    bucket  = ""
    region  = ""
    key     = ""
  }
  required_providers {
    aws = {
      version = "~> 5.42.0"
    }
  }
}

provider "aws" {
  profile = ""
  region  = "ap-south-1"
}
