variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "azure_storage_account_name" {
  description = "Azure storage account name for federation"
  type        = string
}

variable "azure_managed_identity_client_id" {
  description = "Azure managed identity client ID for federation"
  type        = string
}

variable "azure_tenant_id" {
  description = "Azure tenant ID for federation"
  type        = string
}
