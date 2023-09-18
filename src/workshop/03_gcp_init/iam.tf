# workload identity
resource "google_iam_workload_identity_pool" "azure_sts_tenant" {
  depends_on = [
    google_project_service.api,
  ]

  workload_identity_pool_id = "nymeria-identity-pool"
  display_name              = "Azure Cross Cloud IdP"
  description               = "Azure Cross Cloud Identity"
}

resource "google_iam_workload_identity_pool_provider" "azure_sts_tenant" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.azure_sts_tenant.workload_identity_pool_id
  workload_identity_pool_provider_id = "azure-vm"
  display_name                       = "Azure VM"

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
  depends_on = [
    google_project_service.api,
  ]

  account_id   = "nymeria-cross-cloud-sa"
  display_name = "nymeria-cross-cloud-sa"
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

# WARNING: this is the bad way to do this
resource "google_service_account_key" "cross_cloud" {
  service_account_id = google_service_account.cross_cloud.name

  # NOTE: The private_key will be written to the state file.
}
