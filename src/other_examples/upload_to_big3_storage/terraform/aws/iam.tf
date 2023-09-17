data "aws_region" "current" {
}

locals {
  region         = data.aws_region.current.name
  account        = data.aws_caller_identity.current.account_id
  region_account = "${local.region}:${local.account}"
}

data "aws_iam_policy_document" "lambda_assume_role_iam_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
    effect  = "Allow"
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
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_iam_policy.json
}

resource "aws_iam_policy" "upload" {
  name   = "upload-to-big3"
  policy = data.aws_iam_policy_document.upload.json
}

resource "aws_iam_role_policy_attachment" "function" {
  role       = aws_iam_role.upload_to_big3_storage.name
  policy_arn = aws_iam_policy.upload.arn
}

resource "aws_iam_policy" "upload_to_big3_storage_cloudwatch" {
  name   = "upload-to-big3-lambda-cloudwatch"
  policy = data.aws_iam_policy_document.lambda_cloudwatch.json
}
