resource "kubernetes_manifest" "static_credentials_ns" {
  manifest = yamldecode(file("${path.module}/../manifests/static-credentials/ns.yml"))
}

resource "kubernetes_manifest" "workload_identity_ns" {
  manifest = yamldecode(file("${path.module}/../manifests/workload-identity/ns.yml"))
}

resource "kubernetes_manifest" "workload_identity_service_account" {
  manifest = yamldecode(
    templatefile("${path.module}/../manifests/workload-identity/eks/sa.yml",
      {
        aws_iam_role_arn = var.aws_nymeria_iam_role_arn
      }
    )
  )

  depends_on = [kubernetes_manifest.workload_identity_ns]
}
