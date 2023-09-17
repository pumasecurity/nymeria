# Upload Files From Azure

resource "aws_iam_openid_connect_provider" "azure_tenant" {
  url = "https://sts.windows.net/${var.azure_tenant_id}/"
  client_id_list = [var.allowed_jwt_audience]

  # Thumbprint for sts.windows.net
  thumbprint_list = ["626d44e704d1ceabe3bf0d53397464ac8080142c"]
}
