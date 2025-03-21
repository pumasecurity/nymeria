resource "azurerm_resource_group" "federated_identity" {
  name     = var.resource_group_name
  location = var.location
}
