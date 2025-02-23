resource "azurerm_user_assigned_identity" "nymeria" {
  name                = "nymeria-${local.deployment_id}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_federated_identity_credential" "aws_eks" {
  count = var.aws_active ? 1 : 0

  name                = "aws-eks"
  parent_id           = azurerm_user_assigned_identity.nymeria.id
  resource_group_name = azurerm_resource_group.this.name

  audience = [var.workload_identity_audience]
  issuer   = var.aws_eks_cluster_issuer_url
  subject  = "system:serviceaccount:${var.workload_identity_namespace}:${var.workload_identity_service_account}"
}

resource "azurerm_federated_identity_credential" "gcp_gke" {
  count = var.gcp_active ? 1 : 0

  name                = "gcp-gke"
  parent_id           = azurerm_user_assigned_identity.nymeria.id
  resource_group_name = azurerm_resource_group.this.name

  audience = [var.workload_identity_audience]
  issuer   = var.gcp_gke_cluster_issuer_url
  subject  = "system:serviceaccount:${var.workload_identity_namespace}:${var.workload_identity_service_account}"
}
