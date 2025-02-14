variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus2"
}

variable "virtual_machine_size" {
  description = "AKS node instance type"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "tag_owner" {
  description = "Owner of the resources"
  type        = string
  default     = "nymeria"
}

variable "tag_cost_center" {
  description = "Cost center for the resources"
  type        = string
  default     = "rsac"
}
