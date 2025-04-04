resource "google_iam_workload_identity_pool" "nymeria" {
  workload_identity_pool_id = "nymeria-k8s-${local.deployment_id}"
  display_name              = "nymeria-k8s-${local.deployment_id}"
  description               = "Nymeria Kubernetes OIDC Pool"

  depends_on = [
    google_project_service.this,
  ]
}

resource "google_storage_bucket_iam_member" "nymeria_external_pod" {
  bucket = google_storage_bucket.nymeria.name
  role   = "roles/storage.objectViewer"
  member = "principal://iam.googleapis.com/${google_iam_workload_identity_pool.nymeria.name}/subject/system:serviceaccount:${var.workload_identity_namespace}:${var.workload_identity_service_account}"
}

resource "google_iam_workload_identity_pool_provider" "azure_aks_cluster" {
  count = var.azure_active ? 1 : 0

  workload_identity_pool_id          = google_iam_workload_identity_pool.nymeria.workload_identity_pool_id
  workload_identity_pool_provider_id = "azure-aks-${local.deployment_id}"
  display_name                       = "Azure AKS cluster"

  attribute_mapping = {
    "google.subject" = "assertion.sub"
  }

  oidc {
    issuer_uri = var.azure_aks_cluster_issuer_url

    allowed_audiences = [
      var.workload_identity_audience
    ]
  }
}

resource "google_iam_workload_identity_pool_provider" "aws_eks_cluster" {
  count = var.aws_active ? 1 : 0

  workload_identity_pool_id          = google_iam_workload_identity_pool.nymeria.workload_identity_pool_id
  workload_identity_pool_provider_id = "aws-eks-${local.deployment_id}"
  display_name                       = "AWS EKS cluster"

  attribute_mapping = {
    "google.subject" = "assertion.sub"
  }

  oidc {
    issuer_uri = var.aws_eks_cluster_issuer_url

    allowed_audiences = [
      var.workload_identity_audience
    ]
  }
}
