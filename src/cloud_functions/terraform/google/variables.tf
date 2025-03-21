variable "unique_identifier" {
  description = "This is a unique identifier use to uniquely name global resources."
  type        = string
}

variable "api_key" {
  description = "The API key used to invoke the functions."
  type        = string
}

variable "allowed_jwt_audience" {
  description = "The JWT audience that the Workload Identity Federation allows."
  type        = string
}

variable "runtime" {
  description = "The runtime of the functions to use. Must have associated function code."
  type        = string
  default     = "nodejs"

  validation {
    condition     = contains(["nodejs"], var.runtime)
    error_message = "The runtime must be 'nodejs'."
  }
}

variable "google_cloud_project_id" {
  description = "The Google Cloud Platform project ID."
  type        = string
}

variable "google_cloud_region" {
  description = "The Google Cloud Platform region for all the resources."
  type        = string
  default     = "us-east1"
}

variable "aws_iam_role_name" {
  description = "The name of the AWS IAM Role used for federation"
  type        = string
}

variable "aws_iam_role_arn" {
  description = "The ARN of the AWS IAM Role used for federation"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID from which to federate"
  type        = string
}

variable "azure_function_identity_principal_id" {
  description = "Azure Function Identity for federation"
  type        = string
}

variable "azure_tenant_id" {
  description = "Azure AD tenant for federation"
  type        = string
}

variable "azuread_app_id" {
  description = "Azure App Registration Client ID for federation"
  type        = string
}
