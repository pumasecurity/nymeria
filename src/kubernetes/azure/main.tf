data "azurerm_client_config" "this" {}

data "azurerm_subscription" "this" {}

data "azuread_service_principal" "aks" {
  display_name = "Azure Kubernetes Service AAD Server"
}

resource "azurerm_resource_group" "this" {
  name     = local.aks.cluster_name
  location = var.location

  tags = {
    owner       = var.tag_owner
    cost_center = var.tag_cost_center
  }
}
