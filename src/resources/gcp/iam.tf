# workload identity
resource "google_iam_workload_identity_pool" "azure_sts_tenant" {
  workload_identity_pool_id = "cross-cloud-azure-pool"
  display_name              = "Azure Cross Cloud IdP"
  description               = "Azure Cross Cloud Identity"
}

resource "google_iam_workload_identity_pool_provider" "azure_sts_tenant" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.azure_sts_tenant.workload_identity_pool_id
  workload_identity_pool_provider_id = "azure-cross-cloud-vm"
  display_name                       = "Azure Cross Cloud VM"

  attribute_mapping = {
    "google.subject" = "assertion.sub"
  }

  oidc {
    issuer_uri = "https://sts.windows.net/${var.azure_tenant_id}/"

    allowed_audiences = [
      var.azure_virtual_machine_managed_identity_audience
    ]
  }
}

resource "google_service_account_iam_member" "azure_virtual_machine" {
  service_account_id = google_service_account.cross_cloud.name
  member             = "principal://iam.googleapis.com/${google_iam_workload_identity_pool.azure_sts_tenant.name}/subject/${var.azure_virtual_machine_managed_identity_principal_id}"
  role               = "roles/iam.workloadIdentityUser"
}

resource "google_service_account" "cross_cloud" {
  account_id   = "cross-cloud-azure-vm"
  display_name = "cross-cloud-azure-vm"
  description  = "Service Account for Azure VM impersonation."
}

resource "google_storage_bucket_iam_member" "cross_cloud_storage" {
  bucket = google_storage_bucket.cross_cloud.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.cross_cloud.email}"
}

data "template_file" "workload_identity_client_configuration" {
  template = file("${path.module}/assets/gcp-azure-cross-cloud.tpl")

  vars = {
    project_number     = data.google_project.this.number
    project_id         = var.project_id
    identity_pool_id   = google_iam_workload_identity_pool.azure_sts_tenant.workload_identity_pool_id
    provider_id        = google_iam_workload_identity_pool_provider.azure_sts_tenant.workload_identity_pool_provider_id
    service_account_id = google_service_account.cross_cloud.account_id
    jwt_audience       = var.azure_virtual_machine_managed_identity_audience
  }
}
