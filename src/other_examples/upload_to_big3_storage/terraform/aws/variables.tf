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

variable "aws_profile" {
  description = "The AWS profile in the local ~/.aws/config file to use for authentication."
  type        = string
  default     = "default"
}

variable "aws_partition" {
  description = "AWS partition for ARN and URL construction."
  type        = string
  default     = "aws"

  validation {
    condition     = var.aws_partition == "aws" || var.aws_partition == "aws-us-gov"
    error_message = "The AWS partition must be a valid value: [aws-us-gov|aws]."
  }
}

variable "google_cloud_federation_configuration" {
  description = "Base64 encoded client configuration for federating from AWS to Google Cloud."
  type        = string
}
