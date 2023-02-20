variable "location" {
  description = "The location of the resource group containing the federated identity resources."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "The resource group name for the workload resources."
  type        = string
  default     = "federated-identity"
}

variable "github_organization" {
  description = "GitHub Organization hosting the action"
  type        = string
}

variable "github_repository" {
  description = "GitHub Repository hosting the action"
  type        = string
}
