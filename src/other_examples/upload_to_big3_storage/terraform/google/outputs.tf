output "google_function_url" {
  description = "Google Cloud function URL endpoint"
  value       = google_cloudfunctions_function.upload_to_big3_storage.https_trigger_url
}
