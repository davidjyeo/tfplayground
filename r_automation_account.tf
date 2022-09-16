resource "azurerm_automation_account" "south" {
  name                = azurecaf_name.south.results["azurerm_automation_account"]
  location            = azurerm_resource_group.south.location
  resource_group_name = azurerm_resource_group.south.name
  sku_name            = "Basic"

  identity {
    type = "SystemAssigned"
  }

}

# data "local_file" "example" {
#   filename = "./scripts/sync.ps1"
# }

# resource "azurerm_automation_runbook" "source" {
#   name                    = "File-Sync"
#   location                = azurerm_resource_group.south.location
#   resource_group_name     = azurerm_resource_group.south.name
#   automation_account_name = azurerm_automation_account.south.name
#   log_verbose             = "true"
#   log_progress            = "true"
#   runbook_type            = "PowerShell"
#   # runbook_type            = "PowerShellWorkflow"

#   content = data.local_file.example.content

# }