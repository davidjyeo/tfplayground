resource "azurerm_virtual_network" "south" {
  name                = azurecaf_name.south.results["azurerm_virtual_network"]
  location            = azurerm_resource_group.south.location
  resource_group_name = azurerm_resource_group.south.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "south" {
  name                 = azurecaf_name.south.results["azurerm_subnet"]
  resource_group_name  = azurerm_resource_group.south.name
  virtual_network_name = azurerm_virtual_network.south.name
  address_prefixes     = ["10.1.0.64/27"]
}

resource "azurerm_virtual_network" "west" {
  name                = azurecaf_name.west.results["azurerm_virtual_network"]
  location            = azurerm_resource_group.west.location
  resource_group_name = azurerm_resource_group.west.name
  address_space       = ["30.1.0.0/16"]
}

resource "azurerm_subnet" "west" {
  name                 = azurecaf_name.west.results["azurerm_subnet"]
  resource_group_name  = azurerm_resource_group.west.name
  virtual_network_name = azurerm_virtual_network.west.name
  address_prefixes     = ["30.1.0.64/27"]
}