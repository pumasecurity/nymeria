terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.86.0"
    }

    random = {
      source = "hashicorp/random"
    }

    tls = {
      source = "hashicorp/tls"
    }
  }
}
