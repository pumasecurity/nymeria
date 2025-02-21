resource "azurerm_storage_account" "upload_to_big3_storage" {
  name                     = "uploadtobig3${var.unique_identifier}"
  resource_group_name      = azurerm_resource_group.upload_to_big3_storage.name
  location                 = azurerm_resource_group.upload_to_big3_storage.location

  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "upload_to_big3_storage" {
  name                  = "upload-to-big3"
  storage_account_name  = azurerm_storage_account.upload_to_big3_storage.name
  container_access_type = "private"
}
