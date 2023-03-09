resource "aws_iam_openid_connect_provider" "azure_sts_tenant" {
  url = "https://sts.windows.net/${var.azure_tenant_id}/"

  client_id_list = [
    var.azure_virtual_machine_managed_identity_audience,
  ]

  # Thumbprint for sts.windows.net
  #626d44e704d1ceabe3bf0d53397464ac8080142c
  thumbprint_list = [
    "626d44e704d1ceabe3bf0d53397464ac8080142c",
  ]
}

data "aws_iam_policy_document" "azure_virtual_machine" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.azure_sts_tenant.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "sts.windows.net/${var.azure_tenant_id}/:aud"
      values = [
        var.azure_virtual_machine_managed_identity_audience
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "sts.windows.net/${var.azure_tenant_id}/:sub"
      values = [
        var.azure_virtual_machine_managed_identity_principal_id
      ]
    }
  }
}

resource "aws_iam_role" "cross_cloud" {
  name               = "cross-cloud-azure-vm-role"
  path               = "/"
  description        = "IAM Role for Azure VM role assumption."
  assume_role_policy = data.aws_iam_policy_document.azure_virtual_machine.json
}

data "aws_iam_policy_document" "cross_cloud" {
  statement {
    sid    = "S3Read"
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = ["${module.cross_cloud.s3_bucket_arn}/*"]
  }
}

resource "aws_iam_policy" "cross_cloud" {
  name        = "cross-cloud-azure-vm-policy"
  path        = "/"
  description = "IAM policy for Azure VM role assumption."
  policy      = data.aws_iam_policy_document.cross_cloud.json
}

resource "aws_iam_role_policy_attachment" "cross_cloud" {
  role       = aws_iam_role.cross_cloud.name
  policy_arn = aws_iam_policy.cross_cloud.arn
}
