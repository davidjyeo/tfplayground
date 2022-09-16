locals {
  private_dns_zones_names = toset([
    "privatelink.file.core.windows.net",
  ])
}

resource "azurerm_private_dns_zone" "south" {
  for_each            = local.private_dns_zones_names
  name                = each.value
  resource_group_name = azurerm_resource_group.south.name
}

resource "azurerm_public_ip" "south" {
  name                = azurecaf_name.south.results["azurerm_public_ip"]
  sku                 = "Standard"
  location            = azurerm_resource_group.south.location
  resource_group_name = azurerm_resource_group.south.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "south" {
  name                = azurecaf_name.south.results["azurerm_lb"]
  sku                 = "Standard"
  location            = azurerm_resource_group.south.location
  resource_group_name = azurerm_resource_group.south.name

  frontend_ip_configuration {
    name                 = "feip-sync-dev-uks-001"
    public_ip_address_id = azurerm_public_ip.south.id
  }
}

resource "azurerm_private_link_service" "south" {
  name                = "pls-sync-dev-uks-001"
  location            = azurerm_resource_group.south.location
  resource_group_name = azurerm_resource_group.south.name

  auto_approval_subscription_ids = [data.azurerm_subscription.current.subscription_id]
  visibility_subscription_ids    = [data.azurerm_subscription.current.subscription_id]

  nat_ip_configuration {
    name      = azurerm_public_ip.south.name
    subnet_id = azurerm_subnet.service.id
    primary   = true
  }

  load_balancer_frontend_ip_configuration_ids = [azurerm_lb.south.frontend_ip_configuration.0.id]
}

resource "azurerm_private_endpoint" "south" {
  name                = azurecaf_name.south.results["azurerm_private_endpoint"]
  location            = azurerm_resource_group.south.location
  resource_group_name = azurerm_resource_group.south.name
  subnet_id           = azurerm_subnet.endpoint.id

  # private_dns_zone_group {
  #   name                 = "default"
  #   private_dns_zone_ids = [for _, v in azurerm_private_dns_zone.south : v.id]
  # }

  private_service_connection {
    name                           = azurecaf_name.south.results["azurerm_private_service_connection"]
    private_connection_resource_id = azurerm_private_link_service.south.id
    # subresource_names              = ["file"]
    is_manual_connection           = false
  }
}