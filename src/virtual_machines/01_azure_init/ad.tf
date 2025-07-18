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

# GitHub credential (permissions)
resource "azuread_application" "github_federation" {
  display_name    = "github-federation-ad-app"
  identifier_uris = ["api://nymeria-workshop"]

  api {
    requested_access_token_version = 2
  }

  web {
    implicit_grant {
      access_token_issuance_enabled = true
      id_token_issuance_enabled     = true
    }
  }
}

resource "azuread_service_principal" "github_federation" {
  application_id = azuread_application.github_federation.application_id
}

resource "azuread_application_federated_identity_credential" "github_federation" {
  application_object_id = azuread_application.github_federation.id
  display_name          = "github-federation"
  description           = "Deployments for GH Action"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:${var.github_organization}/${var.github_repository}:ref:refs/heads/main"
}

resource "azurerm_role_assignment" "github_federation" {
  principal_id         = azuread_service_principal.github_federation.object_id
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.federated_identity.name}"
  role_definition_name = "Contributor"
}

resource "azurerm_user_assigned_identity" "cross_cloud" {
  name                = "cross-cloud-vm-${random_string.unique_id.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.federated_identity.name
}
