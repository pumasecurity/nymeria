terraform {

  backend "azurerm" {
    container_name = "state"
    key            = "azure.tfstate"
    use_oidc       = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.43.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "2.33.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }

    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

provider "azurerm" {
  use_oidc = true
  features {}
}
