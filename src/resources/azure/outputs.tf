output "azure_tenant_id" {
  description = "Azure tentant id"
  value       = data.azurerm_subscription.current.tenant_id
  sensitive   = true
}

output "ssh_private_key" {
  description = "Private SSH key for instance access."
  value       = trimspace(tls_private_key.ssh_key.private_key_openssh)
  sensitive   = true
}

output "azure_virtual_machine_ip_address" {
  description = "Azure VM public IP fqdn."
  value       = azurerm_public_ip.cross_cloud.fqdn
}

output "azure_virtual_machine_managed_identity_principal_id" {
  description = "Azure VM managed identity principal object id."
  value       = azurerm_linux_virtual_machine.cross_cloud.identity[0].principal_id
}
