variable "location" {
  description = "The location of the resource group containing the federated identity resources."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "The resource group name for the workload resources."
  type        = string
  default     = "nymeria-workshop"
}

variable "github_organization" {
  description = "GitHub Organization hosting the action"
  type        = string
}

variable "github_repository" {
  description = "GitHub Repository hosting the action"
  type        = string
}

variable "virtual_machine_sku" {
  description = "Azure VM SKU size"
  type        = string
  default     = "Standard_A2_v2"
}

variable "admin_cidr_block" {
  description = "Trusted public IP address for SSH."
  type        = string
  default     = "0.0.0.0/0"
}
