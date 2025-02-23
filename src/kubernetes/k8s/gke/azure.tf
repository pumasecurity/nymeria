resource "kubernetes_manifest" "static_credentials_azure_secret" {
  manifest = yamldecode(
    templatefile("${path.module}/../manifests/static-credentials/azure-secret.yml",
      {
        azure_tenant_id     = base64encode(var.azure_nymeria_tenant_id),
        azure_client_id     = base64encode(var.azure_nymeria_service_principal_client_id),
        azure_client_secret = base64encode(var.azure_nymeria_service_principal_client_secret),
      }
    )
  )

  depends_on = [kubernetes_manifest.static_credentials_ns]
}

resource "kubernetes_manifest" "static_credentials_azure_deployment" {
  manifest = yamldecode(
    templatefile("${path.module}/../manifests/static-credentials/azure-deployment.yml",
      {
        nymeria_storage_account = var.azure_nymeria_storage_account_name
      }
    )
  )

  depends_on = [kubernetes_manifest.static_credentials_azure_secret]
}

resource "kubernetes_manifest" "workload_identity_azure_deployment" {
  manifest = yamldecode(
    templatefile("${path.module}/../manifests/workload-identity/azure-deployment.yml",
      {
        nymeria_storage_account = var.azure_nymeria_storage_account_name
        tenant_id               = var.azure_nymeria_tenant_id
        client_id               = var.azure_nymeria_workload_identity_client_id
        azure_oidc_audience     = var.azure_oidc_audience
      }
    )
  )

  depends_on = [kubernetes_manifest.workload_identity_service_account]
}
