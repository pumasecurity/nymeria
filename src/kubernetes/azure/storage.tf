
resource "azurerm_storage_account" "nymeria" {
  name                            = "nymeria${local.deployment_id}"
  resource_group_name             = azurerm_resource_group.this.name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = true
  https_traffic_only_enabled      = true

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_container" "nymeria" {
  name                  = "nymeria"
  storage_account_id    = azurerm_storage_account.nymeria.id
  container_access_type = "container"
}

resource "azurerm_storage_blob" "storage" {
  name                   = "azure-workload-identity.png"
  storage_account_name   = azurerm_storage_account.nymeria.name
  storage_container_name = azurerm_storage_container.nymeria.name
  type                   = "Block"
  source                 = "${path.module}/assets/azure-workload-identity.png"
}

resource "azurerm_role_assignment" "storage_service_principal" {
  principal_id         = azuread_service_principal.nymeria.object_id
  scope                = azurerm_storage_account.nymeria.id
  role_definition_name = "Reader"
}

resource "azurerm_role_assignment" "storage_managed_identity" {
  principal_id         = azurerm_user_assigned_identity.nymeria.principal_id
  scope                = azurerm_storage_account.nymeria.id
  role_definition_name = "Reader"
}
