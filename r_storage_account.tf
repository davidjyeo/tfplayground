resource "azurerm_storage_account" "south" {
  name                     = azurecaf_name.south.results["azurerm_storage_account"]
  resource_group_name      = azurerm_resource_group.south.name
  location                 = azurerm_resource_group.south.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account" "west" {
  name                     = azurecaf_name.west.results["azurerm_storage_account"]
  resource_group_name      = azurerm_resource_group.west.name
  location                 = azurerm_resource_group.west.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "source" {
  name                 = "source"
  storage_account_name = azurerm_storage_account.south.name
  quota                = 5
}

resource "azurerm_storage_share_directory" "source" {
  name                 = "dev"
  share_name           = azurerm_storage_share.source.name
  storage_account_name = azurerm_storage_account.south.name
}

resource "azurerm_storage_share" "target" {
  name                 = "target"
  storage_account_name = azurerm_storage_account.west.name
  quota                = 5
}

resource "azurerm_storage_share_directory" "target" {
  name                 = "dev"
  share_name           = azurerm_storage_share.target.name
  storage_account_name = azurerm_storage_account.west.name
}