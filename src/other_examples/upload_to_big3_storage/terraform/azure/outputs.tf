output "azure_function_host" {
  description = "Azure function URL endpoint"
  value       = azurerm_linux_function_app.upload_to_big3_storage.default_hostname
}
