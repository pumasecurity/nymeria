resource "aws_s3_bucket" "cross_cloud" {
  bucket        = "nymeria-cross-cloud-${random_string.unique_id.result}"
  force_destroy = true
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.cross_cloud.bucket
  key    = "aws-workload-identity.png"
  source = "${path.module}/assets/aws-workload-identity.png"
  etag   = filemd5("${path.module}/assets/aws-workload-identity.png")
}
