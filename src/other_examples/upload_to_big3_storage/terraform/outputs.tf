output "aws_function_url" {
  description = "AWS function URL endpoint"
  value       = module.aws.aws_function_url
}

output "api_key" {
  description = "The API key used to invoke the functions."
  value       = random_string.api_key.result
}
