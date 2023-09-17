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

locals {
  allowed_jwt_audience = "api://upload-to-big-3-${random_string.unique_identifier.result}"
}

module "aws" {
  unique_identifier                     = random_string.unique_identifier.result
  api_key                               = random_string.api_key.result
  allowed_jwt_audience                  = local.allowed_jwt_audience
  runtime                               = var.runtime
  aws_profile                           = var.aws_profile
  aws_partition                         = var.aws_partition
  google_cloud_federation_configuration = module.google.aws_workload_identity_client_configuration
  source                                = "./aws"
}

module "azure" {
  unique_identifier = random_string.unique_identifier.result
  api_key                               = random_string.api_key.result
  allowed_jwt_audience                  = local.allowed_jwt_audience
  runtime                               = var.runtime
  azure_location                        = var.azure_location
  google_cloud_federation_configuration = module.google.azure_workload_identity_client_configuration
  source                                = "./azure"
}

module "google" {
  unique_identifier                    = random_string.unique_identifier.result
  api_key                              = random_string.api_key.result
  allowed_jwt_audience                 = local.allowed_jwt_audience
  runtime                              = var.runtime
  google_cloud_project_id              = var.google_cloud_project_id
  google_cloud_region                  = var.google_cloud_region
  aws_iam_role_name                    = module.aws.aws_iam_role_name
  aws_account_id                       = module.aws.aws_account_id
  azure_function_identity_principal_id = module.azure.azure_function_identity_principal_id
  azure_tenant_id                      = module.azure.azure_tenant_id
  source                               = "./google"
}
