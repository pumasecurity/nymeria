terraform {

  backend "azurerm" {
    resource_group_name  = var.resource_group_name
    storage_account_name = var.tf_state_storage_account_name
    container_name       = "state"
    key                  = "terraform.tfstate"
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
  }
}

provider "azurerm" {
  features {}
}
