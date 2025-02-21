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
  gcp_gke_cluster_audience   = var.gcp_active ? module.gcp[0].nymeria_cluster_issuer : "" # gke issuer and audience identical

  # workload identity configuration
  workload_identity_namespace       = local.kubernetes_workload_identity_namespace
  workload_identity_service_account = local.kubernetes_workload_identity_namespace

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
  workload_identity_service_account = local.kubernetes_workload_identity_namespace

  providers = {
    google = google
  }
}

module "kubernetes_gke" {
  count  = var.gcp_active ? 1 : 0
  source = "./k8s/gke"

  aws_active   = var.aws_active
  azure_active = var.azure_active


  gcp_nymeria_service_account_key = var.gcp_active ? module.gcp[0].nymeria_service_account_key : ""
  gcp_nymeria_storage_bucket      = var.gcp_active ? module.gcp[0].nymeria_storage_bucket : ""

  providers = {
    kubernetes = kubernetes.gke
  }
}
