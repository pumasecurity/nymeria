resource "kubernetes_manifest" "static_credentials_aws_secret" {
  manifest = yamldecode(
    templatefile("${path.module}/../manifests/static-credentials/aws-secret.yml",
      {
        aws_secret_access_key_id = base64encode(var.aws_nymeria_aws_secret_access_key_id),
        aws_secret_access_key    = base64encode(var.aws_nymeria_secret_access_key),
      }
    )
  )

  depends_on = [kubernetes_manifest.static_credentials_ns]
}

resource "kubernetes_manifest" "static_credentials_aws_deployment" {
  manifest = yamldecode(
    templatefile("${path.module}/../manifests/static-credentials/aws-deployment.yml",
      {
        nymeria_s3_bucket = var.aws_nymeria_s3_bucket_name
      }
    )
  )

  depends_on = [kubernetes_manifest.static_credentials_aws_secret]
}


resource "kubernetes_manifest" "workload_identity_aws_deployment" {
  manifest = yamldecode(
    templatefile("${path.module}/../manifests/workload-identity/aks/aws-deployment.yml",
      {
        nymeria_s3_bucket         = var.aws_nymeria_s3_bucket_name
        aws_nymeria_iam_role_arn  = var.aws_nymeria_iam_role_arn
        aws_oidc_audience         = var.aws_oidc_audience
        identity_token_mount_path = var.aws_identity_token_mount_path
      }
    )
  )

  depends_on = [kubernetes_manifest.workload_identity_service_account]
}
