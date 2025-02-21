terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.86.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
  }
}

provider "aws" {
  region = var.region
}
