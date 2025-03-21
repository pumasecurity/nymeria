resource "aws_s3_bucket" "upload_to_big3_storage" {
  bucket        = "upload-to-big3-${var.unique_identifier}"
  force_destroy = true
}
