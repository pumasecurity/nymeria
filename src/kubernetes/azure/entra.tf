# AKS Entra ID admin group
resource "azuread_group" "aks_cluster_admin" {
  display_name     = "dm-aks-cluster-admin"
  owners           = [data.azurerm_client_config.current.object_id]
  security_enabled = true
}

resource "azuread_group_member" "aks_cluster_admin" {
  group_object_id  = azuread_group.aks_cluster_admin.object_id
  member_object_id = data.azurerm_client_config.current.object_id
}
