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
