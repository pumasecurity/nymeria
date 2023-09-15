output "aws_function_url" {
  description = "AWS function URL endpoint"
  value       = aws_lambda_function_url.upload_to_big3_storage.function_url
}
