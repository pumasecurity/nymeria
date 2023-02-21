module "cross_cloud" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.7.0"


  bucket        = "cross-cloud-${random_string.unique_id.result}"
  force_destroy = true

  # bucket ownership
  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  # S3 bucket-level Public Access Block configuration
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "object" {
  bucket = module.cross_cloud.s3_bucket_id
  key    = "workloadidentity.png"
  source = "${path.module}/assets/aws-workload-identity.png"
  etag   = filemd5("${path.module}/assets/aws-workload-identity.png")
}
