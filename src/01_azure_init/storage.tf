resource "azurerm_storage_account" "state" {
  name                      = "terraform${random_string.unique_id.result}"
  resource_group_name       = azurerm_resource_group.federated_identity.name
  location                  = azurerm_resource_group.federated_identity.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true

  blob_properties {
    versioning_enabled = true
  }
}

resource "azurerm_storage_container" "state" {
  name                 = "state"
  storage_account_name = azurerm_storage_account.state.name
}
