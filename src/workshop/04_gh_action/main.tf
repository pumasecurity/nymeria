data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {
}

resource "random_string" "unique_id" {
  length  = 8
  lower   = true
  number  = true
  special = false
  upper   = false
}
