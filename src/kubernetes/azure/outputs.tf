output "nymeria_tenant_id" {
  value = data.azurerm_client_config.this.tenant_id
}

output "nymeria_service_principal_client_id" {
  description = "Nymeria service principal client id"
  value       = azuread_service_principal.nymeria.client_id
}

output "nymeria_service_principal_client_secret" {
  sensitive = true
  value     = azuread_service_principal_password.nymeria.value
}

output "nymeria_workload_identity_client_id" {
  description = "Nymeria managed identity client id"
  value       = azurerm_user_assigned_identity.nymeria.client_id
}

output "nymeria_cluster_endpoint" {
  value = azurerm_kubernetes_cluster.nymeria.kube_config[0].host
}

output "nymeria_cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.nymeria.kube_config[0].cluster_ca_certificate
}

output "nymeria_cluster_issuer" {
  value = azurerm_kubernetes_cluster.nymeria.oidc_issuer_url
}

output "nymeria_storage_account_name" {
  value = azurerm_storage_account.nymeria.name
}
