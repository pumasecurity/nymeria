data "tls_certificate" "aks_cluster" {
  count = var.azure_active ? 1 : 0

  url = var.azure_aks_cluster_issuer_url
}

resource "aws_iam_openid_connect_provider" "aks_cluster" {
  count = var.azure_active ? 1 : 0

  url = var.azure_aks_cluster_issuer_url

  client_id_list = [
    var.workload_identity_audience,
  ]

  thumbprint_list = [
    data.tls_certificate.aks_cluster[0].certificates[0].sha1_fingerprint,
  ]
}

data "tls_certificate" "gke_cluster" {
  count = var.gcp_active ? 1 : 0

  url = var.gcp_gke_cluster_issuer_url
}

resource "aws_iam_openid_connect_provider" "gke_cluster" {
  count = var.gcp_active ? 1 : 0

  url = var.gcp_gke_cluster_issuer_url

  client_id_list = [
    var.workload_identity_audience,
  ]

  thumbprint_list = [
    data.tls_certificate.gke_cluster[0].certificates[0].sha1_fingerprint,
  ]
}

data "aws_iam_policy_document" "nymeria_trust_policy" {
  statement {
    sid     = "AllowEKSAssumeRole"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud"
      values   = [var.workload_identity_audience]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.workload_identity_namespace}:${var.workload_identity_service_account}"]
    }
  }

  dynamic "statement" {
    for_each = var.azure_active ? [1] : []
    content {
      sid     = "AllowAKSAssumeRole"
      actions = ["sts:AssumeRoleWithWebIdentity"]
      effect  = "Allow"

      principals {
        identifiers = [aws_iam_openid_connect_provider.aks_cluster[0].arn]
        type        = "Federated"
      }

      condition {
        test     = "StringEquals"
        variable = "${replace(var.azure_aks_cluster_issuer_url, "https://", "")}:aud"
        values   = [var.workload_identity_audience]
      }

      condition {
        test     = "StringEquals"
        variable = "${replace(var.azure_aks_cluster_issuer_url, "https://", "")}:sub"
        values   = ["system:serviceaccount:${var.workload_identity_namespace}:${var.workload_identity_service_account}"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.gcp_active ? [1] : []
    content {
      sid     = "AllowGCPAssumeRole"
      actions = ["sts:AssumeRoleWithWebIdentity"]
      effect  = "Allow"

      principals {
        identifiers = [aws_iam_openid_connect_provider.gke_cluster[0].arn]
        type        = "Federated"
      }

      condition {
        test     = "StringEquals"
        variable = "${replace(var.gcp_gke_cluster_issuer_url, "https://", "")}:aud"
        values   = [var.workload_identity_audience]
      }

      condition {
        test     = "StringEquals"
        variable = "${replace(var.gcp_gke_cluster_issuer_url, "https://", "")}:sub"
        values   = ["system:serviceaccount:${var.workload_identity_namespace}:${var.workload_identity_service_account}"]
      }
    }
  }
}

resource "aws_iam_role" "nymeria" {
  name               = "nymeria-${local.deployment_id}"
  path               = "/"
  description        = "IAM role for CloudWatch audit logging"
  assume_role_policy = data.aws_iam_policy_document.nymeria_trust_policy.json
}

resource "aws_iam_role_policy_attachment" "nymeria" {
  role       = aws_iam_role.nymeria.name
  policy_arn = aws_iam_policy.nymeria.arn
}
