output "google_function_url" {
  description = "Google Cloud function URL endpoint"
  value       = google_cloudfunctions_function.upload_to_big3_storage.https_trigger_url
}

output "google_service_account_id" {
  description = "The ID of the Google Cloud Service Account used for federation"
  value       = google_service_account.upload_to_big3_storage.unique_id
}

output "aws_workload_identity_client_configuration" {
  value = data.template_file.aws_workload_identity_client_configuration.rendered
}

output "azure_workload_identity_client_configuration" {
  value = data.template_file.azure_workload_identity_client_configuration.rendered
}
