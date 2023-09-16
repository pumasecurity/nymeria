variable "unique_identifier" {
  description = "This is a unique identifier use to uniquely name global resources."
  type        = string
}

variable "api_key" {
  description = "The API key used to invoke the functions."
  type        = string
}

variable "azure_location" {
  description = "The location of the resource group containing the Cougar resources."
  type        = string
  default     = "centralus"
}
