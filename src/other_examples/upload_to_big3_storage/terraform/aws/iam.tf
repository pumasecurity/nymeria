data "aws_region" "current" {
}

locals {
  region         = data.aws_region.current.name
  account        = data.aws_caller_identity.current.account_id
  region_account = "${local.region}:${local.account}"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
    effect  = "Allow"
  }

  # Upload Files From Azure

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
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

  # Upload Files From Google

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = ["accounts.google.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "accounts.google.com:oaud"
      values = [var.allowed_jwt_audience]
    }

    condition {
      test     = "StringEquals"
      variable = "accounts.google.com:sub"
      values = [var.google_service_account_id]
    }
  }
}

data "aws_iam_policy_document" "upload" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.upload_to_big3_storage.arn}/*"]
    effect    = "Allow"
  }
}

data "aws_iam_policy_document" "lambda_cloudwatch" {
  statement {
    actions = [
      "logs:CreateLogGroup"
    ]

    resources = ["arn:aws:logs:${local.region_account}:*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:${local.region_account}:log-group:/aws/lambda/*:*"
    ]

    effect = "Allow"
  }
}

resource "aws_iam_role" "upload_to_big3_storage" {
  name               = "upload-to-big3"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "upload" {
  name   = "upload-to-big3"
  policy = data.aws_iam_policy_document.upload.json
}

resource "aws_iam_role_policy_attachment" "upload_to_big3_storage" {
  role       = aws_iam_role.upload_to_big3_storage.name
  policy_arn = aws_iam_policy.upload.arn
}

resource "aws_iam_policy" "upload_to_big3_storage_cloudwatch" {
  name   = "upload-to-big3-lambda-cloudwatch"
  policy = data.aws_iam_policy_document.lambda_cloudwatch.json
}
