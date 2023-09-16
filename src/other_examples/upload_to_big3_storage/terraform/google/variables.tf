variable "unique_identifier" {
  description = "This is a unique identifier use to uniquely name global resources."
  type        = string
}

variable "api_key" {
  description = "The API key used to invoke the functions."
  type        = string
}

variable "google_cloud_project_id" {
  description = "The Google Cloud Platform project ID."
  type        = string
}

variable "google_cloud_region" {
  description = "The Google Cloud Platform region for all the resources."
  type        = string
  default     = "us-east1"
}

