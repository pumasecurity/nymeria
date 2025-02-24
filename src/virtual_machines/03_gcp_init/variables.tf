variable "project_id" {
  description = "The Google Cloud Platform project ID."
  type        = string
}

variable "region" {
  description = "The Google Cloud Platform region for all the resources."
  type        = string
  default     = "us-east1"
}

variable "azure_tenant_id" {
  description = "Azure tentant id"
  type        = string
}

variable "azure_virtual_machine_managed_identity_principal_id" {
  description = "Azure Virtual Machine MSI object id"
  type        = string
}

variable "azure_virtual_machine_managed_identity_audience" {
  description = "Azure Virtual Machine MSI audience"
  type        = string
  default     = "api://nymeria-workshop"
}
