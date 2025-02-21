resource "azurerm_container_registry" "nymeria" {
  name                = "nymeria${local.deployment_id}" # Names only allow alphanumeric characters, lowercase recommended
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Basic"
}
