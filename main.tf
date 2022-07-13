resource "azurerm_resource_group" "example" {
  name     = "peering-rg"
  location = "UK South"
}

resource "azurerm_virtual_network" "example-1" {
  name                = "uks-dv-crleg-01-vnet"
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.1.0/24"]
  location            = azurerm_resource_group.example.location
}

resource "azurerm_virtual_network" "example-2" {
  name                = "uk-sh-idmz-01-vnet"
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.2.0/24"]
  location            = azurerm_resource_group.example.location
}

resource "azurerm_virtual_network_peering" "example-1" {
  name                      = "${azurerm_virtual_network.example-1.name}-to-${azurerm_virtual_network.example-2.name}"
  resource_group_name       = azurerm_resource_group.example.name
  virtual_network_name      = azurerm_virtual_network.example-1.name
  remote_virtual_network_id = azurerm_virtual_network.example-2.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false

  # use_remote_gateways = true
}

resource "azurerm_virtual_network_peering" "example-2" {
name                      = "${azurerm_virtual_network.example-2.name}-to-${azurerm_virtual_network.example-1.name}"
  resource_group_name       = azurerm_resource_group.example.name
  virtual_network_name      = azurerm_virtual_network.example-2.name
  remote_virtual_network_id = azurerm_virtual_network.example-1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = true
  # use_remote_gateways = true
}