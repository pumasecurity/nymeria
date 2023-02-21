resource "random_string" "unique_id" {
  length  = 8
  lower   = true
  number  = true
  special = false
  upper   = false
}
