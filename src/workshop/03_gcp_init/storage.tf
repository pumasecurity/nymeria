resource "google_storage_bucket" "cross_cloud" {
  depends_on = [
    google_project_service.api,
  ]

  name     = "nymeria-cross-cloud-${random_string.unique_id.result}"
  location = var.region

  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "cross_cloud" {
  bucket = google_storage_bucket.cross_cloud.name

  name   = "gcp-workload-identity.png"
  source = "${path.module}/assets/gcp-workload-identity.png"
}
