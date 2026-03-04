# Upload Files From AWS

resource "azuread_application" "aws" {
  display_name    = "upload-to-big3-storage-aws"
  identifier_uris = [var.allowed_jwt_audience]

  web {
    implicit_grant {
      access_token_issuance_enabled = true
      id_token_issuance_enabled     = true
    }
  }
}

resource "azuread_service_principal" "aws" {
  application_id = azuread_application.aws.application_id
}

resource "azuread_application_federated_identity_credential" "aws" {
  application_object_id = azuread_application.google.id
  display_name          = "upload-to-big3-storage-aws"
  audiences             = [var.allowed_jwt_audience]
  issuer                = var.aws_iam_outbound_issuer
  subject               = "arn:aws:iam::${var.aws_account_id}:role/${var.aws_iam_role_name}"
}

# Upload Files From Google Cloud

resource "azuread_application" "google" {
  display_name    = "upload-to-big3-storage-google"
  identifier_uris = [var.allowed_jwt_audience]

  web {
    implicit_grant {
      access_token_issuance_enabled = true
      id_token_issuance_enabled     = true
    }
  }
}

resource "azuread_service_principal" "google" {
  application_id = azuread_application.google.application_id
}

resource "azuread_application_federated_identity_credential" "google" {
  application_object_id = azuread_application.google.id
  display_name          = "upload-to-big3-storage-google"
  audiences             = [var.allowed_jwt_audience]
  issuer                = "https://accounts.google.com"
  subject               = var.google_service_account_id
}
