resource "azurerm_automation_account" "south" {
  name                = azurecaf_name.south.results["azurerm_automation_account"]
  location            = azurerm_resource_group.south.location
  resource_group_name = azurerm_resource_group.south.name
  sku_name            = "Basic"

  identity {
    type = "SystemAssigned"
  }

}