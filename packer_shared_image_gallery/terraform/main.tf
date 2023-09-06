module "naming" {
  source = "Azure/naming/azurerm"
  suffix = ["AZDEV-YEOD-PACKER"]
}

resource "azurerm_shared_image_gallery" "sig" {
  name                = "sig_azdev_yeod_packer" #lower(replace("$(module.naming.shared_image_gallery.name)", "-", "_")) #)
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = lower(module.naming.virtual_network.name)
  address_space       = ["131.200.0.0/16"]
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "snet" {
  name                 = lower(module.naming.network_interface.name)
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["131.200.2.0/24"]
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
}

# resource "azurerm_public_ip" "pip" {
#   name                = lower(module.naming.public_ip.name)
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   allocation_method   = "Dynamic"

#   tags = {
#     environment = "PoC"
#   }
# }
