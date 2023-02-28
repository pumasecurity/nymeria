output "gcs_bucket" {
  description = "GCS bucket with cross cloud data."
  value       = google_storage_bucket.cross_cloud.name
}

output "workload_identity_client_configuration" {
  description = "Workload Identity client configuration file"
  value       = data.template_file.workload_identity_client_configuration.rendered
}
