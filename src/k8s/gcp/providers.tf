terraform {

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.20.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
  }
}

provider "google" {
  project         = var.project_id
  region          = var.region
  request_timeout = "120s"

  default_labels = {
    owner       = var.tag_owner
    cost_center = var.tag_cost_center
  }
}
