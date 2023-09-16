terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.82.0"
    }
  }
}

provider "google" {
  project = var.google_cloud_project_id
  region  = var.google_cloud_region
}
