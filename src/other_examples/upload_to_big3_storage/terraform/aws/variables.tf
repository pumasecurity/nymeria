variable "unique_identifier" {
  description = "This is a unique identifier use to uniquely name global resources."
  type        = string
}

variable "api_key" {
  description = "The API key used to invoke the functions."
  type        = string
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
