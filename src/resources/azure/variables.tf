variable "location" {
  description = "The location of the resource group containing the federated identity resources."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "The resource group name for the workload resources."
  type        = string
}

variable "tf_state_storage_account_name" {
  description = "Terraform state storage account name."
  type        = string
}

variable "virtual_machine_sku" {
  description = "Azure VM SKU size"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "admin_cidr_block" {
  description = "Trusted public IP address for SSH."
  type        = string
  default     = "0.0.0.0/0"
}
