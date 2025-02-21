resource "azurerm_kubernetes_cluster" "nymeria" {
  name                             = local.aks.cluster_name
  location                         = azurerm_resource_group.this.location
  resource_group_name              = azurerm_resource_group.this.name
  dns_prefix                       = local.aks.cluster_name
  azure_policy_enabled             = false
  http_application_routing_enabled = false

  # enable workload identity integrations
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # configure Entra ID / K8s RBAC integrations
  role_based_access_control_enabled = true
  azure_active_directory_role_based_access_control {
    tenant_id              = data.azurerm_client_config.this.tenant_id
    admin_group_object_ids = [azuread_group.aks_cluster_admin.object_id]
  }

  default_node_pool {
    name           = "system"
    node_count     = 1
    vm_size        = var.virtual_machine_size
    vnet_subnet_id = azurerm_subnet.private.id
    max_pods       = 50
    upgrade_settings {
      max_surge = "10%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    service_cidr      = local.aks.services_cidr
    dns_service_ip    = local.aks.dns_service_ip
    load_balancer_sku = "standard"
  }

  lifecycle {
    ignore_changes = [
      microsoft_defender
    ]
  }
}

resource "null_resource" "wait_for_cluster" {
  provisioner "local-exec" {
    command = <<EOT
      sleep 30
    EOT
  }

  triggers = {
    runOnce = "True"
  }

  depends_on = [azurerm_kubernetes_cluster.nymeria]
}

resource "azurerm_role_assignment" "nymeria_network" {
  principal_id         = azurerm_kubernetes_cluster.nymeria.identity[0].principal_id
  role_definition_name = "Network Contributor"
  scope                = azurerm_subnet.private.id

  depends_on = [null_resource.wait_for_cluster]
}
