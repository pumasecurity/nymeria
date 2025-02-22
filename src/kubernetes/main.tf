module "azure" {
  count  = var.azure_active ? 1 : 0
  source = "./azure"

  location             = var.azure_location
  virtual_machine_size = var.azure_virtual_machine_size

  aws_active = var.aws_active
  # aws_eks_cluster_issuer_url = module.aws.nymeria_cluster_issuer_url
  # aws_eks_cluster_audience = module.aws.nymeria_cluster_audience

  gcp_active                 = var.gcp_active
  gcp_gke_cluster_issuer_url = var.gcp_active ? module.gcp[0].nymeria_cluster_issuer : ""
  gcp_gke_cluster_audience   = local.azure_oidc_audience

  # workload identity configuration
  workload_identity_namespace       = local.kubernetes_workload_identity_namespace
  workload_identity_service_account = local.kubernetes_workload_identity_service_account

  providers = {
    azurerm = azurerm
    azuread = azuread
  }
}

module "gcp" {
  count  = var.gcp_active ? 1 : 0
  source = "./gcp"

  region     = var.gcp_region
  project_id = var.gcp_project_id

  # workload identity configuration
  workload_identity_namespace       = local.kubernetes_workload_identity_namespace
  workload_identity_service_account = local.kubernetes_workload_identity_service_account

  providers = {
    google = google
  }
}

module "kubernetes_gke" {
  count  = var.gcp_active ? 1 : 0
  source = "./k8s/gke"

  aws_active        = var.aws_active
  aws_oidc_audience = local.aws_oidc_audience

  azure_active                                  = var.azure_active
  azure_nymeria_tenant_id                       = var.azure_active ? module.azure[0].nymeria_tenant_id : ""
  azure_nymeria_service_principal_client_id     = var.azure_active ? module.azure[0].nymeria_service_principal_client_id : ""
  azure_nymeria_service_principal_client_secret = var.azure_active ? module.azure[0].nymeria_service_principal_client_secret : ""
  azure_nymeria_workload_identity_client_id     = var.azure_active ? module.azure[0].nymeria_workload_identity_client_id : ""
  azure_nymeria_storage_account_name            = var.azure_active ? module.azure[0].nymeria_storage_account_name : ""
  azure_oidc_audience                           = local.azure_oidc_audience

  gcp_nymeria_service_account_key = var.gcp_active ? module.gcp[0].nymeria_service_account_key : ""
  gcp_nymeria_storage_bucket      = var.gcp_active ? module.gcp[0].nymeria_storage_bucket : ""

  providers = {
    kubernetes = kubernetes.gke
  }
}
