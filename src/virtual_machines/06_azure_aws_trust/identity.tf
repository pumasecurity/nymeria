resource "azurerm_federated_identity_credential" "aws" {
  name                = "nymeria-aws"
  resource_group_name = var.azure_resource_group_name
  parent_id           = var.azure_managed_identity_id

  issuer   = var.aws_account_issuer
  audience = ["api://AzureADTokenExchange"]
  subject  = var.aws_iam_role_arn
}
