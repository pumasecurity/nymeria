locals {
  kubernetes_workload_identity_namespace       = "workload-identity"
  kubernetes_workload_identity_service_account = "nymeria"

  aws_oidc_audience             = "sts.amazonaws.com"
  aws_identity_token_mount_path = "/var/run/secrets/aws/serviceaccount"

  azure_oidc_audience               = "api://AzureADTokenExchange"
  azure_identity_token_mount_path   = "/var/run/secrets/azure/serviceaccount"
  azure_aks_entra_id_application_id = "6dae42f8-4368-4678-94ff-3960e28e3630"

  gcp_oidc_audience             = "sts.googleapis.com"
  gcp_identity_token_mount_path = "/var/run/secrets/gcp/serviceaccount"
}
