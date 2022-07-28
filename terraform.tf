# Make sure to set the following environment variables:
#   AZDO_PERSONAL_ACCESS_TOKEN - wyh63rba6brtilczm6lxgiigbf2zl3322zbjz54gqeimnxluvfnq
#   AZDO_ORG_SERVICE_URL - https://dev.azure.com/az-400-djy/

terraform {
  required_providers {
    azuredevops = {
      source = "microsoft/azuredevops"
    }
  }
}

provider "azuredevops" {
  personal_access_token = "fx75tknoetwwiooma6ohfppdoz5sgtbtpzyxlngvry6w7b6sxhja"
  org_service_url       = "https://dev.azure.com/az-400-djy/"
}
