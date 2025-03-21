resource "azurerm_virtual_network" "vnet" {
  name                = local.aks.cluster_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = [local.network_addresses.network_cidr_block]
}

resource "azurerm_subnet" "app_gw_public" {
  name                 = "${local.aks.cluster_name}-public"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.network_addresses.subnet_app_gw_public_cidr_block]
}

resource "azurerm_network_security_group" "app_gw_public" {
  name                = "${azurerm_subnet.app_gw_public.name}-nsg"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

resource "azurerm_network_security_rule" "app_gw_public_https" {
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.app_gw_public.name

  name                       = "public_https"
  priority                   = 300
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  source_address_prefix      = "0.0.0.0/0"
  destination_port_range     = "443"
  destination_address_prefix = local.network_addresses.subnet_app_gw_public_cidr_block
}

resource "azurerm_network_security_rule" "app_gw_manager" {
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.app_gw_public.name

  name                       = "public_app_gw"
  priority                   = 400
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  source_address_prefix      = "GatewayManager"
  destination_port_range     = "65200-65535"
  destination_address_prefix = "*"
}

resource "azurerm_subnet_network_security_group_association" "app_gw_public" {
  subnet_id                 = azurerm_subnet.app_gw_public.id
  network_security_group_id = azurerm_network_security_group.app_gw_public.id
}

resource "azurerm_subnet" "private" {
  name                 = "${local.aks.cluster_name}-private"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.network_addresses.subnet_private_cidr_block]
}

resource "azurerm_network_security_group" "private" {
  name                = "${azurerm_subnet.private.name}-nsg"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

resource "azurerm_network_security_rule" "private_web" {
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.private.name

  name                       = "inbound_service_https"
  priority                   = 200
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  source_address_prefix      = local.network_addresses.subnet_app_gw_public_cidr_block
  destination_port_range     = "8443"
  destination_address_prefix = "*"
}

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.private.id
}
