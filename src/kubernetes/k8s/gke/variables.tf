variable "aws_active" {
  description = "Enable AWS pod resources"
  type        = bool
  default     = false
}

variable "aws_nymeria_aws_secret_access_key_id" {
  description = "Nymeria AWS secret access key id"
  type        = string
}

variable "aws_nymeria_secret_access_key" {
  description = "Nymeria AWS secret access key"
  type        = string
}

variable "aws_nymeria_iam_role_arn" {
  description = "Nymeria AWS IAM Role ARN"
  type        = string
}

variable "aws_nymeria_s3_bucket_name" {
  description = "Nymeria AWS S3 bucket"
  type        = string
}

variable "aws_oidc_audience" {
  description = "AWS service account token audience"
  type        = string
}

variable "aws_identity_token_mount_path" {
  description = "AWS identity token mount path"
  type        = string
  default     = ""
}

variable "azure_active" {
  description = "Enable Azure pod resources"
  type        = bool
  default     = false
}

variable "azure_nymeria_tenant_id" {
  description = "Nymeria tenant id"
  type        = string
}

variable "azure_nymeria_service_principal_client_id" {
  description = "Nymeria service principal client id"
  type        = string
}

variable "azure_nymeria_service_principal_client_secret" {
  description = "Nymeria service principal client secret"
  type        = string
}

variable "azure_nymeria_workload_identity_client_id" {
  description = "Nymeria managed identity client id"
  type        = string
}

variable "azure_nymeria_storage_account_name" {
  description = "Nymeria Azure storage account name"
  type        = string
}

variable "azure_oidc_audience" {
  description = "Azure service account token audience"
  type        = string
}

variable "azure_identity_token_mount_path" {
  description = "Azure identity token mount path"
  type        = string
  default     = ""
}

variable "gcp_nymeria_service_account_key" {
  description = "Nymeria static service account key (base64 encoded)"
  type        = string
}

variable "gcp_nymeria_storage_bucket" {
  description = "Nymeria GCS storage bucket"
  type        = string
}
