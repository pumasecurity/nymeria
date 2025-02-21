terraform {
  required_providers {

    azurerm = {
      source = "hashicorp/azurerm"
    }

    azuread = {
      source = "hashicorp/azuread"
    }

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
  }
}

provider "azurerm" {
  subscription_id = var.azure_subscription_id

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy = false
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
