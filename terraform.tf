terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    azurecaf = {
      source = "aztfmod/azurecaf"
    }
    tls = {
      source = "hashicorp/tls"
    }
    local = {
      source = "hashicorp/local"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

# provider "azurerm" {
#   features {}
#   alias = "ukwest"
# }

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}