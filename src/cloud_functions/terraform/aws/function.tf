data "archive_file" "upload_to_big3_storage_build" {
  type        = "zip"
  source_dir  = "${path.module}/../../functions/${var.runtime}/upload"
  output_path = "/tmp/upload-to-big3-${var.runtime}-aws.zip"
}

resource "aws_lambda_function" "upload_to_big3_storage" {
  function_name    = "upload-to-big3"
  description      = "Cloud function for uploading a file to the Big 3 cloud storage services (where possible) from each cloud provider using Workload Identity Federation."
  runtime          = var.runtime == "nodejs" ? "nodejs20.x" : ""
  handler          = "index.handler"
  role             = aws_iam_role.upload_to_big3_storage.arn
  filename         = data.archive_file.upload_to_big3_storage_build.output_path
  source_code_hash = data.archive_file.upload_to_big3_storage_build.output_base64sha256
  timeout          = 5

  environment {
    variables = {
      UNIQUE_IDENTIFIER                     = var.unique_identifier
      API_KEY                               = var.api_key
      ALLOWED_JWT_AUDIENCE                  = var.allowed_jwt_audience
      AZURE_TENANT_ID                       = var.azure_tenant_id
      AZURE_CLIENT_ID                       = var.azure_aws_service_principal_client_id
      GOOGLE_CLOUD_FEDERATION_CONFIGURATION = var.google_cloud_federation_configuration
    }
  }
}

resource "aws_lambda_function_url" "upload_to_big3_storage" {
  function_name      = aws_lambda_function.upload_to_big3_storage.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_permission" "allow_public_invocation" {
  action                   = "lambda:InvokeFunction"
  function_name            = aws_lambda_function.upload_to_big3_storage.function_name
  principal                = "*"
}

resource "aws_lambda_permission" "allow_public_invocation_url" {
  action                   = "lambda:InvokeFunctionUrl"
  function_name            = aws_lambda_function.upload_to_big3_storage.function_name
  principal                = "*"
  function_url_auth_type   = "NONE"
}
