output "azure_vm_aws_role_arn" {
  description = "Azure VM AWS Role ARN"
  value       = aws_iam_role.cross_cloud.arn
}

output "azure_vm_aws_access_key_id" {
  value     = aws_iam_access_key.long_lived_credential.id
  sensitive = true
}

output "azure_vm_aws_secret_access_key" {
  value     = aws_iam_access_key.long_lived_credential.secret
  sensitive = true
}

output "aws_s3_bucket" {
  description = "AWS bucket with cross cloud data"
  value       = aws_s3_bucket.cross_cloud.bucket
}

output "aws_default_region" {
  description = "AWS default region"
  value       = var.region
}
