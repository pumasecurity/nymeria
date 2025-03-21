variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus2"
}

variable "virtual_machine_size" {
  description = "AKS node instance type"
  type        = string
}

variable "aws_active" {
  description = "Enable AWS OIDC federation"
  type        = bool
  default     = false
}

variable "aws_eks_cluster_issuer_url" {
  description = "AWS EKS cluster OIDC issuer URL"
  type        = string
  default     = ""
}

variable "gcp_active" {
  description = "Enable GCP OIDC federation"
  type        = bool
  default     = false
}

variable "gcp_gke_cluster_issuer_url" {
  description = "GKE cluster OIDC issuer URL"
  type        = string
  default     = ""
}

variable "workload_identity_audience" {
  description = "Incoming OIDC audience from external clusters"
  type        = string
}

variable "workload_identity_namespace" {
  description = "Kubernetes workload identity namespace"
  type        = string
  default     = ""
}

variable "workload_identity_service_account" {
  description = "Kubernetes workload identity service account"
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
