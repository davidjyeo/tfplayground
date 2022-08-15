resource "azurerm_resource_group" "south" {
  name     = azurecaf_name.south.results["azurerm_resource_group"]
  location = "uksouth"

  lifecycle {
    create_before_destroy = true
  }
}