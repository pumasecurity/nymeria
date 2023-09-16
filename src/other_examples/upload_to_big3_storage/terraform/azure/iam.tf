data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "upload" {
  scope              = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.upload_to_big3_storage.name}/providers/Microsoft.Storage/storageAccounts/${azurerm_storage_account.upload_to_big3_storage.name}/blobServices/default/containers/${azurerm_storage_container.upload_to_big3_storage.name}"

  # Storage Blob Data Contributor
  role_definition_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe"

  principal_id       = azurerm_linux_function_app.upload_to_big3_storage.identity[0].principal_id
}
