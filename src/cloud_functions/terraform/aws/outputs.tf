output "aws_function_url" {
  description = "AWS function URL endpoint"
  value       = aws_lambda_function_url.upload_to_big3_storage.function_url
}

output "aws_iam_role_name" {
  description = "The name of the AWS IAM Role used for federation"
  value       = aws_iam_role.upload_to_big3_storage.name
}

output "aws_account_id" {
  description = "AWS Account ID from which to federate"
  value       = data.aws_caller_identity.current.account_id
}

output "azure_aws_iam_role_arn" {
  description = "The ARN of the AWS IAM Role used for federation from Azure"
  value       = aws_iam_role.azure.arn
}

output "google_aws_iam_role_arn" {
  description = "The ARN of the AWS IAM Role used for federation from Google"
  value       = aws_iam_role.google.arn
}
