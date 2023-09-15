data "archive_file" "upload_to_big3_storage_build" {
  type        = "zip"
  source_dir  = "${path.module}/../../functions/nodejs"
  output_path = "${path.module}/../functions/nodejs.zip"
}

resource "aws_lambda_function" "upload_to_big3_storage" {
  function_name    = "upload-to-big3-${var.unique_identifier}"
  description      = "Cloud function for uploading a file to the Big 3 cloud storage services (where possible) from each cloud provider using Workload Identity Federation."
  runtime          = "nodejs18.x"
  handler          = "index.handler"
  role             = aws_iam_role.function.arn
  filename         = "${path.module}/../functions/nodejs.zip"
  source_code_hash = data.archive_file.upload_to_big3_storage_build.output_base64sha256

  environment {
    variables = {
      UNIQUE_IDENTIFIER = var.unique_identifier
      API_KEY           = var.api_key
    }
  }
}

resource "aws_lambda_function_url" "upload_to_big3_storage" {
  function_name      = aws_lambda_function.upload_to_big3_storage.function_name
  authorization_type = "NONE"
}
