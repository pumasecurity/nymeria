output "gcs_bucket" {
  description = "GCS bucket with cross cloud data."
  value       = google_storage_bucket.cross_cloud.name
}

# todo output the client library config 
