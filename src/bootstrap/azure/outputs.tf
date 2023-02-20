output "github_service_principal_client_id" {
  description = "GH Action application (client) id"
  value       = azuread_application.github.application_id
  sensitive   = true
}

output "github_service_principal_client_secret" {
  description = "GH Action service principal client secret"
  value       = azuread_application_password.github.value
  sensitive   = true
}

output "azure_tenant_id" {
  description = "Azure tentant id"
  value       = data.azurerm_subscription.current.tenant_id
  sensitive   = true
}

output "azure_subscription_id" {
  description = "Azure subscription id"
  value       = data.azurerm_subscription.current.subscription_id
  sensitive   = true
}

output "resource_group_name" {
  description = "Azure Resource group container name"
  value       = azurerm_resource_group.federated_identity.name
}

output "terraform_state_storage_account_name" {
  description = "Storage account name for the Terraform state"
  value       = azurerm_storage_account.state.name
}
