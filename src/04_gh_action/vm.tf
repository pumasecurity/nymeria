resource "azurerm_virtual_network" "cross_cloud" {
  name                = "nymeria-${random_string.unique_id.result}"
  address_space       = ["10.42.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "cross_cloud" {
  name                 = "nymeria-public-subnet-${random_string.unique_id.result}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.cross_cloud.name
  address_prefixes     = ["10.42.0.0/24"]
}

resource "azurerm_public_ip" "cross_cloud" {
  name                = "nymeria-public-ip-${random_string.unique_id.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  domain_name_label   = "cross-cloud-${random_string.unique_id.result}"
}

resource "azurerm_network_interface" "cross_cloud" {
  name                = "nymeria-nic-${random_string.unique_id.result}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "nymeria-nic-${random_string.unique_id.result}"
    subnet_id                     = azurerm_subnet.cross_cloud.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.cross_cloud.id
  }
}

resource "azurerm_network_security_group" "cross_cloud" {
  name                = "nymeria-nsg-${random_string.unique_id.result}"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.admin_cidr_block
    destination_address_prefix = "${azurerm_network_interface.cross_cloud.private_ip_address}/32"
  }
}

resource "azurerm_network_interface_security_group_association" "cross_cloud" {
  network_interface_id      = azurerm_network_interface.cross_cloud.id
  network_security_group_id = azurerm_network_security_group.cross_cloud.id
}

# RSA key of size 4096 bits
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "template_file" "startup_script" {
  template = file("${path.module}/templates/startup.tpl")

  vars = {
    aws_default_region       = var.aws_default_region
    aws_access_key_id        = var.aws_access_key_id
    aws_secret_access_key    = var.aws_secret_access_key
    aws_s3_bucket_id         = var.aws_s3_bucket_id
    aws_cross_cloud_role_arn = var.aws_cross_cloud_role_arn

    google_cloud_project_id                             = var.google_cloud_project_id
    google_cloud_service_account_key                    = base64decode(var.google_cloud_service_account_key)
    google_cloud_workload_identity_client_configuration = base64decode(var.google_cloud_workload_identity_client_configuration)
    gcs_s3_bucket_id                                    = var.gcs_s3_bucket_id
  }
}

resource "azurerm_linux_virtual_machine" "cross_cloud" {
  name                            = "cross-cloud-${random_string.unique_id.result}"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  network_interface_ids           = [azurerm_network_interface.cross_cloud.id]
  size                            = var.virtual_machine_sku
  computer_name                   = "nymeria"
  admin_username                  = "ubuntu"
  disable_password_authentication = true

  custom_data = base64encode(join("\n", [
    data.template_file.startup_script.rendered,
  ]))

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    name                 = "cross-cloud-${random_string.unique_id.result}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username   = "ubuntu"
    public_key = trimspace(tls_private_key.ssh_key.public_key_openssh)
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      var.azure_virtual_machine_managed_identity_id
    ]
  }
}
