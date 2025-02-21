data "archive_file" "upload_to_big3_storage_build" {
  type        = "zip"
  source_dir  = "${path.module}/../../functions/${var.runtime}/upload"
  output_path = "/tmp/upload-to-big3-${var.runtime}-google.zip"
}

resource "google_storage_bucket" "upload_to_big3_storage_function" {
  name     = "upload-to-big3-function-${var.unique_identifier}"
  location = var.google_cloud_region
}

resource "google_storage_bucket_object" "upload_to_big3_storage_function" {
  name   = "${data.archive_file.upload_to_big3_storage_build.output_md5}.zip"
  bucket = google_storage_bucket.upload_to_big3_storage_function.name
  source = data.archive_file.upload_to_big3_storage_build.output_path
}


resource "google_cloudfunctions_function" "upload_to_big3_storage" {
  name                  = "upload-to-big3"
  runtime               = var.runtime == "nodejs" ? "nodejs18" : ""

  source_archive_bucket = google_storage_bucket.upload_to_big3_storage_function.name
  source_archive_object = google_storage_bucket_object.upload_to_big3_storage_function.name
  trigger_http          = true
  entry_point           = "handler"
  service_account_email = google_service_account.upload_to_big3_storage.email

  environment_variables = {
    UNIQUE_IDENTIFIER          = var.unique_identifier
    API_KEY                    = var.api_key
    ALLOWED_JWT_AUDIENCE       = var.allowed_jwt_audience
    AWS_ROLE_ARN               = var.aws_iam_role_arn
    AZURE_AD_APP_ID            = var.azuread_app_id
    AZURE_TENANT_ID            = var.azure_tenant_id
  }
}
