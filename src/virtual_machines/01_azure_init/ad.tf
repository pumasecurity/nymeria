# Long-lived credential (no permissions)
resource "azuread_application" "github_creds" {
  display_name = "github-creds-ad-app"
}

resource "azuread_service_principal" "github_creds" {
  application_id = azuread_application.github_creds.application_id
}

resource "azuread_application_password" "github_creds" {
  application_object_id = azuread_application.github_creds.id
  display_name          = "github-creds-long-lived"
  end_date_relative     = "24h" # short window for the workshop
}

resource "azurerm_role_assignment" "github_creds" {
  principal_id         = azuread_service_principal.github_creds.object_id
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.federated_identity.name}"
  role_definition_name = "Reader"
}

# GitHub federated identity
resource "azurerm_user_assigned_identity" "github" {
  name                = "nymeria-federation"
  location            = azurerm_resource_group.federated_identity.location
  resource_group_name = azurerm_resource_group.federated_identity.name
}

resource "azurerm_federated_identity_credential" "github" {
  name                = "nymeria-github"
  resource_group_name = azurerm_resource_group.federated_identity.name
  parent_id           = azurerm_user_assigned_identity.github.id

  issuer   = "https://token.actions.githubusercontent.com"
  audience = ["api://AzureADTokenExchange"]
  subject  = "repo:${var.github_organization}/${var.github_repository}:ref:refs/heads/main"
}

resource "azurerm_role_assignment" "github_contributor" {
  principal_id         = azurerm_user_assigned_identity.github.principal_id
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.federated_identity.name}"
  role_definition_name = "Contributor"
}

resource "azurerm_user_assigned_identity" "cross_cloud" {
  name                = "cross-cloud-vm-${random_string.unique_id.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.federated_identity.name
}

resource "azurerm_role_assignment" "cross_cloud_storage" {
  principal_id         = azurerm_user_assigned_identity.cross_cloud.principal_id
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.federated_identity.name}"
  role_definition_name = "Reader and Data Access"
}

resource "azurerm_role_assignment" "cross_cloud_blob_reader" {
  principal_id         = azurerm_user_assigned_identity.cross_cloud.principal_id
  scope                = azurerm_storage_account.cross_cloud.id
  role_definition_name = "Storage Blob Data Reader"
}
