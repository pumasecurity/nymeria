output "azure_vm_aws_role_arn" {
  description = "Azure VM AWS Role ARN"
  value       = aws_iam_role.cross_cloud.arn
}

output "aws_s3_bucket" {
  description = "AWS bucket with cross cloud data"
  value       = module.cross_cloud.s3_bucket_id
}
