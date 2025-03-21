resource "google_storage_bucket" "nymeria" {
  name     = "nymeria-${local.deployment_id}"
  location = var.region

  force_destroy               = true
  uniform_bucket_level_access = true

  depends_on = [
    google_project_service.this,
  ]
}

resource "google_storage_bucket_object" "nymeria" {
  bucket = google_storage_bucket.nymeria.name

  name   = "gcp-workload-identity.png"
  source = "${path.module}/assets/gcp-workload-identity.png"
}

# standard service account permissions (static key, external cloud federation)
resource "google_storage_bucket_iam_member" "nymeria_sa" {
  bucket = google_storage_bucket.nymeria.name
  role   = "roles/storage.objectViewer"
  member = google_service_account.nymeria.member
}

# GKE pod permissions
resource "google_storage_bucket_iam_member" "nymeria_gke_pod" {
  bucket = google_storage_bucket.nymeria.name
  role   = "roles/storage.objectViewer"
  member = "principal://iam.googleapis.com/projects/${data.google_project.this.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/${var.workload_identity_namespace}/sa/${var.workload_identity_service_account}"
}

