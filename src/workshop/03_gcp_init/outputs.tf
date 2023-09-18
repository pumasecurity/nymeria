output "gcs_bucket" {
  description = "GCS bucket with cross cloud data"
  value       = google_storage_bucket.cross_cloud.name
}

output "workload_identity_client_configuration" {
  description = "Workload Identity client configuration file"
  value       = base64encode(data.template_file.workload_identity_client_configuration.rendered)
}

output "azure_vm_google_service_account_key" {
  value     = google_service_account_key.cross_cloud.private_key
  sensitive = true
}

output "gcp_project_id" {
  value = data.google_project.this.project_id
}
