# AKS Entra ID admin group
resource "azuread_group" "aks_cluster_admin" {
  display_name     = "dm-aks-cluster-admin"
  owners           = [data.azurerm_client_config.this.object_id]
  security_enabled = true
}

resource "azuread_group_member" "aks_cluster_admin" {
  group_object_id  = azuread_group.aks_cluster_admin.object_id
  member_object_id = data.azurerm_client_config.this.object_id
}

resource "azuread_application" "nymeria" {
  display_name = "nymeria-${local.deployment_id}"
}

resource "azuread_service_principal" "nymeria" {
  client_id = azuread_application.nymeria.client_id
}

resource "azuread_service_principal_password" "nymeria" {
  service_principal_id = azuread_service_principal.nymeria.id
  display_name         = "nymeria-${local.deployment_id}"
  end_date             = timeadd(timestamp(), "720h") # 30 days

  lifecycle {
    ignore_changes = [end_date]
  }
}
