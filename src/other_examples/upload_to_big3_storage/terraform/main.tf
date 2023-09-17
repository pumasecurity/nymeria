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
  api_key                               = random_string.api_key.result
  runtime                               = var.runtime
  aws_profile                           = var.aws_profile
  aws_partition                         = var.aws_partition
  google_cloud_federation_configuration = module.google.aws_workload_identity_client_configuration
  source                                = "./aws"
}

module "azure" {
  unique_identifier = random_string.unique_identifier.result
  api_key           = random_string.api_key.result
  runtime           = var.runtime
  azure_location    = var.azure_location
  source            = "./azure"
}

module "google" {
  unique_identifier       = random_string.unique_identifier.result
  api_key                 = random_string.api_key.result
  runtime                 = var.runtime
  google_cloud_project_id = var.google_cloud_project_id
  google_cloud_region     = var.google_cloud_region
  aws_iam_role_name       = module.aws.aws_iam_role_name
  aws_account_id          = module.aws.aws_account_id
  source                  = "./google"
}
