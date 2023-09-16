resource "random_string" "unique_identifier" {
  length  = 8
  special = false
  upper   = false
  lower   = true
  numeric = true
}

resource "random_string" "api_key" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}

module "aws" {
  unique_identifier = random_string.unique_identifier.result
  api_key           = random_string.api_key.result
  aws_profile       = var.aws_profile
  aws_partition     = var.aws_partition
  source            = "./aws"
}

module "azure" {
  unique_identifier = random_string.unique_identifier.result
  api_key           = random_string.api_key.result
  azure_location    = var.azure_location
  source            = "./azure"
}

#module "google" {
#  unique_identifier = random_string.unique_identifier.result
#  api_key           = random_string.api_key.result
#  source            = "./google"
#}
