resource "kubernetes_manifest" "static_credentials_gcp_secret" {
  manifest = yamldecode(
    templatefile("${path.module}/../manifests/static-credentials/gcp-secret.yml",
      {
        service_account_key = var.gcp_nymeria_service_account_key
      }
    )
  )

  depends_on = [kubernetes_manifest.static_credentials_ns]
}


resource "kubernetes_manifest" "static_credentials_gcp_deployment" {
  manifest = yamldecode(
    templatefile("${path.module}/../manifests/static-credentials/gcp-deployment.yml",
      {
        nymeria_storage_bucket = var.gcp_nymeria_storage_bucket
      }
    )
  )

  depends_on = [kubernetes_manifest.static_credentials_gcp_secret]
}

resource "kubernetes_manifest" "workload_identity_gcp_deployment" {
  manifest = yamldecode(
    templatefile("${path.module}/../manifests/workload-identity/gcp-deployment.yml",
      {
        nymeria_storage_bucket = var.gcp_nymeria_storage_bucket
      }
    )
  )

  depends_on = [kubernetes_manifest.workload_identity_service_account]
}
