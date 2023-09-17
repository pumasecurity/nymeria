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

variable "google_cloud_federation_configuration" {
  description = "Base64 encoded client configuration for federating from Azure to Google Cloud."
  type        = string
}
