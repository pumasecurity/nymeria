variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-west2"
}

variable "project_id" {
  description = "GCP project id"
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

variable "aws_eks_cluster_audience" {
  description = "Azure AKS cluster OIDC audience"
  type        = string
  default     = "sts.amazonaws.com"

}

variable "azure_active" {
  description = "Enable Azure OIDC federation"
  type        = bool
  default     = false

}

variable "azure_aks_cluster_issuer_url" {
  description = "Azure AKS cluster OIDC issuer URL"
  type        = string
  default     = ""
}

variable "azure_aks_cluster_audience" {
  description = "Azure AKS cluster OIDC audience"
  type        = string
  default     = "api://AzureADTokenExchange"
}

variable "workload_identity_namespace" {
  description = "Kubernetes workload identity namespace"
  type        = string
}

variable "workload_identity_service_account" {
  description = "Kubernetes workload identity service account"
  type        = string
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
