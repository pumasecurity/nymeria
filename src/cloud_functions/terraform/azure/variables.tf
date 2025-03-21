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

variable "azure_location" {
  description = "The location of the resource group containing the Cougar resources."
  type        = string
  default     = "centralus"
}

variable "aws_iam_role_arn" {
  description = "The ARN of the AWS IAM Role used for federation"
  type        = string
}

variable "google_service_account_id" {
  description = "The ID of the Google Cloud Service Account used for federation"
  type        = string
}

variable "google_cloud_federation_configuration" {
  description = "Client configuration for federating from AWS to Google Cloud."
  type        = string
}
