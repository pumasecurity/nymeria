resource "google_storage_bucket" "upload_to_big3_storage" {
  name                        = "upload-to-big3-${var.unique_identifier}"
  location                    = var.google_cloud_region
  force_destroy               = true
}
