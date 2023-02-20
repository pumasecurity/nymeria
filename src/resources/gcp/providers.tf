terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.7.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

provider "google" {
  project         = var.GcpProjectId
  region          = var.GcpRegion
  request_timeout = "120s"
}
