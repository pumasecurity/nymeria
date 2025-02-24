terraform {
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "5.86.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.20.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "3.1.0"
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

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Owner      = var.tag_owner
      CostCenter = var.tag_cost_center
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
  alias = "eks"

  host                   = module.aws[0].nymeria_cluster_endpoint
  cluster_ca_certificate = base64decode(module.aws[0].nymeria_cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.aws[0].nymeria_cluster_name]
    command     = "aws"
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
