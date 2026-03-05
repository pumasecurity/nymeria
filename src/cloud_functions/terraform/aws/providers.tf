terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.34.0"
    }
  }
}

provider "aws" {
  profile = var.aws_profile
}

data "aws_caller_identity" "current" {
}
