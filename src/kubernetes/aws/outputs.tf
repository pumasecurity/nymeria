output "nymeria_aws_secret_access_key_id" {
  description = "Nymeria IAM user secret access key"
  value       = aws_iam_access_key.nymeria.id
  sensitive   = true
}

output "nymeria_secret_access_key" {
  description = "Nymeria IAM user secret access key"
  value       = aws_iam_access_key.nymeria.secret
  sensitive   = true
}

output "nymeria_role_arn" {
  description = "Nymeria IAM role arn"
  value       = aws_iam_role.nymeria.arn
}

output "nymeria_cluster_endpoint" {
  value = aws_eks_cluster.nymeria.endpoint
}

output "nymeria_cluster_ca_certificate" {
  value = aws_eks_cluster.nymeria.certificate_authority[0].data
}

output "nymeria_cluster_issuer_url" {
  value = aws_eks_cluster.nymeria.identity[0].oidc[0].issuer
}

output "nymeria_s3_bucket_name" {
  value = aws_s3_bucket.nymeria.bucket
}
