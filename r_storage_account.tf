resource "azurerm_storage_account" "south_01" {
  name                     = azurecaf_name.south.results["azurerm_storage_account"]
  resource_group_name      = azurerm_resource_group.south.name
  location                 = azurerm_resource_group.south.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account" "south_02" {
  name                     = "stsyncdevuks002"
  resource_group_name      = azurerm_resource_group.south.name
  location                 = azurerm_resource_group.south.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "source" {
  name                 = "source"
  storage_account_name = azurerm_storage_account.south_01.name
  quota                = 5
}

resource "azurerm_storage_share" "target" {
  name                 = "target"
  storage_account_name = azurerm_storage_account.south_02.name
  quota                = 5
}