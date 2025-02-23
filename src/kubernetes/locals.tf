locals {
  kubernetes_workload_identity_namespace       = "workload-identity"
  kubernetes_workload_identity_service_account = "nymeria"

  aws_oidc_audience   = "sts.amazonaws.com"
  azure_oidc_audience = "api://AzureADTokenExchange"
  gcp_oidc_audience   = "sts.googleapis.com"
}
