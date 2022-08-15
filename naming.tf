resource "azurecaf_name" "south" {
    name            = lower("sync-dev-uks")
    resource_types  = ["azurerm_resource_group",
                       "azurerm_virtual_network",
                       "azurerm_subnet",
                       "azurerm_automation_account",
                       "azurerm_public_ip",
                       "azurerm_route_table",
                       "azurerm_network_interface",
                       "azurerm_storage_account",
                       "azurerm_network_security_group",
                       "azurerm_network_security_group_rule",
                       "azurerm_linux_virtual_machine",
                       "azurerm_virtual_network_gateway",
                       "azurerm_virtual_network_peering",
                       "azurerm_private_endpoint",
                       "azurerm_private_service_connection"]
    suffixes        = ["001"]
    clean_input     = true
    use_slug        = true
}

# resource "azurecaf_name" "west" {
#     name            = lower("sync-dev-ukw")
#     resource_types  = ["azurerm_resource_group",
#                        "azurerm_virtual_network",
#                        "azurerm_subnet",
#                        "azurerm_public_ip",
#                        "azurerm_route_table",
#                        "azurerm_network_interface",
#                        "azurerm_storage_account",
#                        "azurerm_network_security_group",
#                        "azurerm_network_security_group_rule",
#                        "azurerm_private_endpoint",
#                        "azurerm_private_endpoint_connection"]
#     suffixes        = ["001"]
#     clean_input     = true
#     use_slug        = true
# }