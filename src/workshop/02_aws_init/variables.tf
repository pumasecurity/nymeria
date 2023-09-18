variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "azure_tenant_id" {
  description = "Azure tentant id"
  type        = string
}

variable "azure_virtual_machine_managed_identity_principal_id" {
  description = "Azure Vitrual Machine MSI object id"
  type        = string
}

variable "azure_virtual_machine_managed_identity_audience" {
  description = "Azure Virtual Machine MSI audience"
  type        = string
  default     = "api://nymeria-workload-identity"
}
