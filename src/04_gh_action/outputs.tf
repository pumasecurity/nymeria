output "ssh_private_key" {
  description = "Private SSH key for instance access."
  value       = trimspace(tls_private_key.ssh_key.private_key_openssh)
  sensitive   = true
}

output "azure_virtual_machine_fqdn" {
  description = "Azure VM public IP fqdn."
  value       = azurerm_public_ip.cross_cloud.fqdn
}
