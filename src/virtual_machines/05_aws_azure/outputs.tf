output "account_issuer_endpoint" {
  description = "Account token issuer endpoint."
  value       = aws_iam_outbound_web_identity_federation.this.issuer_identifier
}

output "iam_role_arn" {
  description = "The ARN of the IAM role to be assumed from Azure."
  value       = aws_iam_role.cross_cloud.arn
}

output "nymeria_instance_id" {
  description = "The ID of the Nymeria instance."
  value       = aws_instance.cross_cloud.id
}
