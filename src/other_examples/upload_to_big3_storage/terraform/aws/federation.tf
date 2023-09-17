# Upload Files From Azure

resource "aws_iam_openid_connect_provider" "azure_tenant" {
  url = "https://sts.windows.net/${var.azure_tenant_id}/"
  client_id_list = [var.allowed_jwt_audience]

  # Thumbprint for sts.windows.net
  thumbprint_list = ["626d44e704d1ceabe3bf0d53397464ac8080142c"]
}

data "aws_iam_policy_document" "assume_role_azure_before" {
  statement {
    effect  = "Deny"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

data "aws_iam_policy_document" "assume_role_azure_after" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.azure_tenant.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "sts.windows.net/${var.azure_tenant_id}/:aud"
      values = [var.allowed_jwt_audience]
    }

    condition {
      test     = "StringEquals"
      variable = "sts.windows.net/${var.azure_tenant_id}/:sub"
      values = [
        var.azure_function_identity_principal_id
      ]
    }
  }
}

resource "aws_iam_role" "azure" {
  name               = "upload-to-big3-azure"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_azure_before.json

  lifecycle {
    ignore_changes = [assume_role_policy]
  }  
}

# Update Assume Role Policy after creating the role. Required to avoid a cyclical dependency.
# Reference: https://github.com/hashicorp/terraform-provider-aws/issues/7922#issuecomment-1340573375
resource "null_resource" "add_worker_node_assume_role_policy" {
  provisioner "local-exec" {
    command = "sleep 5; aws iam update-assume-role-policy --role-name ${aws_iam_role.azure.name} --policy-document '${self.triggers.updated_policy_json}'"
  }

  triggers = {
    updated_policy_json = (replace(replace(data.aws_iam_policy_document.assume_role_azure_after.json,"\n", "")," ", ""))
    after               = aws_iam_role.azure.assume_role_policy
  }
}

# Upload Files From Google

data "aws_iam_policy_document" "assume_role_google" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["accounts.google.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "accounts.google.com:oaud"
      values   = [var.allowed_jwt_audience]
    }

    condition {
      test     = "StringEquals"
      variable = "accounts.google.com:sub"
      values   = [var.google_service_account_id]
    }
  }
}

resource "aws_iam_role" "google" {
  name               = "upload-to-big3-google"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_google.json
}
