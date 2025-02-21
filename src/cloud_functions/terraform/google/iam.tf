resource "google_service_account" "upload_to_big3_storage" {
  account_id = "upload-to-big3-storage"
}

resource "google_project_iam_custom_role" "upload" {
  role_id     = "upload_to_big3_storage"
  title       = "Upload objects whether or not they exist (requires delete permission)."
  permissions = ["storage.objects.create", "storage.objects.delete"]
}

resource "google_storage_bucket_iam_binding" "upload" {
  bucket = google_storage_bucket.upload_to_big3_storage.name
  role   = google_project_iam_custom_role.upload.id
  members = ["serviceAccount:${google_service_account.upload_to_big3_storage.email}"]
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = var.google_cloud_project_id
  region         = var.google_cloud_region

  cloud_function = google_cloudfunctions_function.upload_to_big3_storage.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}
