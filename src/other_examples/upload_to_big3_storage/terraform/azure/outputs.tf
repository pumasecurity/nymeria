data "azurerm_client_config" "current" {}

output "azure_function_host" {
  description = "Azure function URL endpoint"
  value       = azurerm_linux_function_app.upload_to_big3_storage.default_hostname
}

output "azure_function_identity_principal_id" {
  description = "Azure Function Identity for federation"
  value       = azurerm_linux_function_app.upload_to_big3_storage.identity.0.principal_id
}

output "azure_tenant_id" {
  description = "Azure AD tenant for federation"
  value       = data.azurerm_client_config.current.tenant_id
}

output "google_azuread_app_id" {
  description = "Azure App Registration Client ID for federation from Google"
  value       = azuread_application.google.application_id
}
