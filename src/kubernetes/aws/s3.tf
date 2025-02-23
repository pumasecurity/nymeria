resource "aws_s3_bucket" "nymeria" {
  bucket        = "nymeria-${local.deployment_id}"
  force_destroy = true
}

resource "aws_s3_object" "nymeria" {
  bucket = aws_s3_bucket.nymeria.bucket
  key    = "aws-workload-identity.png"
  source = "${path.module}/assets/aws-workload-identity.png"
  etag   = filemd5("${path.module}/assets/aws-workload-identity.png")
}
