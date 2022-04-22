resource "azurerm_resource_group" "example" {
  name     = "rg-storage"
  location = "UK South"
}

resource "azurerm_storage_account" "example" {
  name                     = "djytempstgacct"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}

resource "azurerm_storage_share" "example" {
  name                 = "shareazcopy-test"
  storage_account_name = azurerm_storage_account.example.name
  quota                = 10
}