variable "location" {
  description = "The location of the resource group containing the federated identity resources"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "The resource group name for the workload resources"
  type        = string
}

variable "virtual_machine_sku" {
  description = "Azure VM SKU size"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "admin_cidr_block" {
  description = "Trusted public IP address for SSH"
  type        = string
  default     = "0.0.0.0/0"
}

variable "azure_virtual_machine_managed_identity_id" {
  description = "Azure VM managed identity id"
  type        = string
}

variable "aws_default_region" {
  description = "AWS default region"
  type        = string
}

variable "aws_access_key_id" {
  description = "AWS access key id"
  type        = string
}

variable "aws_secret_access_key" {
  description = "AWS access key id"
  type        = string
}

variable "aws_cross_cloud_role_arn" {
  description = "AWS cross cloud role ARN"
  type        = string
}

variable "aws_s3_bucket_id" {
  description = "AWS S3 bucket id"
  type        = string
}

variable "google_cloud_project_id" {
  description = "GCP project id"
  type        = string
}
variable "google_cloud_service_account_key" {
  description = "GCP service account key file"
  type        = string
}

variable "google_cloud_workload_identity_client_configuration" {
  description = "GCP workload identity client configuration"
  type        = string
}

variable "gcs_bucket_id" {
  description = "AWS S3 bucket id"
  type        = string
}
