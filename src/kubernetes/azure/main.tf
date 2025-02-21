data "azurerm_client_config" "this" {}

data "azurerm_subscription" "this" {}

resource "azurerm_resource_group" "this" {
  name     = local.aks.cluster_name
  location = var.location

  tags = {
    owner       = var.tag_owner
    cost_center = var.tag_cost_center
  }
}
