terraform {

  backend "azurerm" {
    container_name = "state"
    key            = "google.tfstate"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.53.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

provider "google" {
  project         = var.project_id
  region          = var.region
  request_timeout = "120s"
}
