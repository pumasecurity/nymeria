terraform {

  backend "azurerm" {
    container_name = "state"
    key            = "aws.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.55.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

provider "aws" {
  region = var.region
}
