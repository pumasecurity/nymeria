resource "azurerm_resource_group" "upload_to_big3_storage" {
  name     = "uploadtobig3"
  location = var.azure_location
}
