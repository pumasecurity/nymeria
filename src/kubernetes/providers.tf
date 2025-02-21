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
  project         = var.gcp_project_id
  region          = var.gcp_region
  request_timeout = "120s"

  default_labels = {
    owner       = var.tag_owner
    cost_center = var.tag_cost_center
  }
}

provider "kubernetes" {
  alias = "gke"

  host  = "https://${module.gcp[0].nymeria_cluster_endpoint}"
  token = module.gcp[0].gcp_client_config_access_token
  cluster_ca_certificate = base64decode(
    module.gcp[0].nymeria_cluster_ca_certificate
  )
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "gke-gcloud-auth-plugin"
  }
}
