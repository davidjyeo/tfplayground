resource "azurerm_resource_group" "south" {
  name     = azurecaf_name.south.results["azurerm_resource_group"]
  location = "uksouth"

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_resource_group" "west" {
  name     = azurecaf_name.west.results["azurerm_resource_group"]
  location = "ukwest"

  lifecycle {
    create_before_destroy = true
  }
}