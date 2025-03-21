resource "kubernetes_manifest" "static_credentials_ns" {
  manifest = yamldecode(file("${path.module}/../manifests/static-credentials/ns.yml"))
}

resource "kubernetes_manifest" "workload_identity_ns" {
  manifest = yamldecode(file("${path.module}/../manifests/workload-identity/ns.yml"))
}

resource "kubernetes_manifest" "workload_identity_service_account" {
  manifest = yamldecode(
    templatefile("${path.module}/../manifests/workload-identity/aks/sa.yml",
      {
        managed_identity_client_id = var.azure_nymeria_workload_identity_client_id
        managed_identity_tenant_id = var.azure_nymeria_tenant_id
      }
    )
  )

  depends_on = [kubernetes_manifest.workload_identity_ns]
}
