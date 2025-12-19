variable "azure_resource_group_name" {
  description = "The name of the resource group where the federated identity is created."
  type        = string
}

variable "azure_managed_identity_id" {
  description = "The ID of the Azure Managed Identity to be used for federated identity."
  type        = string
}

variable "aws_account_issuer" {
  description = "The AWS Account issuer to establish trust with."
  type        = string
}

variable "aws_iam_role_arn" {
  description = "The AWS Role ARN allowed to login with the managed identity."
  type        = string
}
