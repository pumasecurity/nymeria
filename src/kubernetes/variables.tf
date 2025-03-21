variable "aws_active" {
  description = "Activate AWS EKS deployment"
  type        = bool
  default     = false
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "aws_eks_instance_type" {
  description = "EKS node instance type"
  type        = string
  default     = "t3.xlarge"
}

variable "azure_active" {
  description = "Activate Azure AKS deployment"
  type        = bool
  default     = false
}

variable "azure_subscription_id" {
  description = "Azure subscription id"
  type        = string
}

variable "azure_location" {
  description = "Azure location"
  type        = string
  default     = "eastus2"
}

variable "azure_virtual_machine_size" {
  description = "AKS node instance type"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "gcp_active" {
  description = "Activate GCP GKE deployment"
  type        = bool
  default     = false
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-west2"
}

variable "gcp_project_id" {
  description = "GCP project id"
  type        = string
  default     = ""
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
