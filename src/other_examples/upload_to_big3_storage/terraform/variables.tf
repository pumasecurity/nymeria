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

variable "azure_location" {
  description = "The location of the resource group containing the Cougar resources."
  type        = string
  default     = "centralus"
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

