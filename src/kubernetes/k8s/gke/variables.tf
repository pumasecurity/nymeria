variable "aws_active" {
  description = "Enable AWS pod resources"
  type        = bool
  default     = false
}

variable "azure_active" {
  description = "Enable Azure pod resources"
  type        = bool
  default     = false
}

variable "gcp_nymeria_service_account_key" {
  description = "Nymeria static service account key (base64 encoded)"
  type        = string
}

variable "gcp_nymeria_storage_bucket" {
  description = "Nymeria static service account key (base64 encoded)"
  type        = string
}
