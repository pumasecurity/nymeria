module "gcp" {
  count  = var.gcp_active ? 1 : 0
  source = "./gcp"

  region     = var.gcp_region
  project_id = var.gcp_project_id

  # gke vars
  gke_workload_identity_namespace       = var.gcp_active ? module.kubernetes_gke[0].workload_identity_namespace : ""
  gke_workload_identity_service_account = var.gcp_active ? module.kubernetes_gke[0].workload_identity_service_account : ""

  providers = {
    google = google
  }
}

module "kubernetes_gke" {
  count  = var.gcp_active ? 1 : 0
  source = "./k8s/gke"

  gcp_nymeria_service_account_key = var.gcp_active ? module.gcp[0].nymeria_service_account_key : ""
  gcp_nymeria_storage_bucket      = var.gcp_active ? module.gcp[0].nymeria_storage_bucket : ""

  providers = {
    kubernetes = kubernetes.gke
  }
}
