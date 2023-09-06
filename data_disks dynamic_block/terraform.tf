terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
  # client_id       = "72bc5457-b923-4a41-ad7d-6bc057088c24" # var.clientID 
  # client_secret   = "MarvintheMartian2023!"                # var.clientSecret
  # tenant_id       = "7299adcc-d0dc-42e5-8f17-4d733225f022" # var.tenantID
  # subscription_id = "feb03ea6-86ca-4e65-b397-3d1362520d9b" # var.subscriptionID
}

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}
