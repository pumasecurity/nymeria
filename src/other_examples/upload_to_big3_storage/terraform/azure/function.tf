data "archive_file" "upload_to_big3_storage_build" {
  type        = "zip"
  source_dir  = "${path.module}/../../functions/nodejs"
  output_path = "/tmp/upload-to-big3-nodejs-azure.zip"
}

# Reference: https://adrianhall.github.io/typescript/2019/10/23/terraform-functions/
data "azurerm_storage_account_sas" "functions" {
  connection_string = azurerm_storage_account.upload_to_big3_storage_function.primary_connection_string
  https_only        = true
  start             = formatdate("YYYY-MM-DD", timeadd(timestamp(), "-48h"))
  expiry            = formatdate("YYYY-MM-DD", timeadd(timestamp(), "17520h"))

  resource_types {
    object    = true
    container = false
    service   = false
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}

resource "azurerm_storage_account" "upload_to_big3_storage_function" {
  name                     = "uploadtobig3func${var.unique_identifier}"
  resource_group_name      = azurerm_resource_group.upload_to_big3_storage.name
  location                 = azurerm_resource_group.upload_to_big3_storage.location

  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "upload_to_big3_storage_function" {
  name                 = "function-releases"
  storage_account_name = azurerm_storage_account.upload_to_big3_storage_function.name
}

resource "azurerm_storage_blob" "upload_to_big3_storage" {
  name                   = "functionapp.zip"
  storage_account_name   = azurerm_storage_account.upload_to_big3_storage_function.name
  storage_container_name = azurerm_storage_container.upload_to_big3_storage_function.name
  type                   = "Block"
  source                 = data.archive_file.upload_to_big3_storage_build.output_path
  content_md5            = filemd5(data.archive_file.upload_to_big3_storage_build.output_path)
}

resource "azurerm_service_plan" "upload_to_big3_storage" {
  name                = "upload-to-big3"
  resource_group_name = azurerm_resource_group.upload_to_big3_storage.name
  location            = azurerm_resource_group.upload_to_big3_storage.location

  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "upload_to_big3_storage" {
  name                       = "upload-to-big3-${var.unique_identifier}"
  resource_group_name        = azurerm_resource_group.upload_to_big3_storage.name
  location                   = azurerm_resource_group.upload_to_big3_storage.location

  storage_account_name       = azurerm_storage_account.upload_to_big3_storage_function.name
  storage_account_access_key = azurerm_storage_account.upload_to_big3_storage_function.primary_access_key
  service_plan_id            = azurerm_service_plan.upload_to_big3_storage.id

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME    = "node"
    FUNCTION_APP_EDIT_MODE      = "readonly"
    FUNCTIONS_EXTENSION_VERSION = "~4"
    HASH                        = "${base64encode(filesha256(data.archive_file.upload_to_big3_storage_build.output_path))}"
    WEBSITE_RUN_FROM_PACKAGE    = "https://${azurerm_storage_account.upload_to_big3_storage_function.name}.blob.core.windows.net/${azurerm_storage_container.upload_to_big3_storage_function.name}/${azurerm_storage_blob.upload_to_big3_storage.name}${data.azurerm_storage_account_sas.functions.sas}"
    UNIQUE_IDENTIFIER           = var.unique_identifier
    API_KEY                     = var.api_key
  }

  site_config {
    application_stack {
      node_version = "18"
    }

    cors {
      allowed_origins = ["*"]
    }
  }

  identity {
    type = "SystemAssigned"
  }
}
