output "gcp_client_config_access_token" {
  value     = data.google_client_config.this.access_token
  sensitive = true
}

output "gcp_project_number" {
  value = data.google_project.this.number
}

output "nymeria_cluster_endpoint" {
  value = google_container_cluster.nymeria.endpoint
}

output "nymeria_cluster_ca_certificate" {
  value = google_container_cluster.nymeria.master_auth[0].cluster_ca_certificate
}

output "nymeria_cluster_issuer" {
  value = google_container_cluster.nymeria.self_link
}

output "nymeria_service_account_email" {
  value     = google_service_account.nymeria.email
  sensitive = true
}

output "nymeria_service_account_key" {
  value     = google_service_account_key.nymeria.private_key
  sensitive = true
}

output "nymeria_storage_bucket" {
  value = google_storage_bucket.nymeria.name
}
