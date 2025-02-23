variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "eks_instance_type" {
  description = "EKS node instance type"
  type        = string
  default     = "t3.large"
}

variable "azure_active" {
  description = "Enable Azure OIDC federation"
  type        = bool
  default     = false
}

variable "azure_aks_cluster_issuer_url" {
  description = "Azure Kubernetes cluster OIDC issuer URL"
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
  default     = ""
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
