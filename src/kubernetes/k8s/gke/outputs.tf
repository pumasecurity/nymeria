output "workload_identity_namespace" {
  value = kubernetes_manifest.workload_identity_ns.manifest.metadata.name
}

output "workload_identity_service_account" {
  value = kubernetes_manifest.workload_identity_service_account.manifest.metadata.name
}
