variable "data_disk_count" {
  default = 5
}

module "naming" {
  source = "Azure/naming/azurerm"
  suffix = ["AZDEV-YEOD"]
}

resource "azurerm_resource_group" "rg" {
  name     = "AZDEV-YEOD-AT-AZLLOYDSDEV-DOT-COM"
  location = "UK South"
}

resource "azurerm_shared_image_gallery" "sig" {
  name                = lower(module.naming.shared_image_gallery.name)
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = lower(module.naming.virtual_network.name)
  address_space       = ["131.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "snet" {
  name                 = lower(module.naming.network_interface.name)
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["131.200.2.0/24"]
  resource_group_name  = azurerm_resource_group.rg.name
}

resource "azurerm_public_ip" "pip" {
  name                = lower(module.naming.public_ip.name)
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "PoC"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = lower(module.naming.network_interface.name)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                          = lower(module.naming.virtual_machine.name)
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  primary_network_interface_id  = azurerm_network_interface.nic.id
  network_interface_ids         = [azurerm_network_interface.nic.id]
  vm_size                       = "Standard_B4ls_v2"
  delete_os_disk_on_termination = "true"

  storage_os_disk {
    name              = "vm-os-disk"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    create_option     = "FromImage"
  }

  dynamic "storage_data_disk" {
    iterator = disk
    for_each = range(var.data_disk_count)
    content {
      name                      = lower(format("${module.naming.managed_disk.name}-%02d", disk.key + 1))
      caching                   = "ReadWrite"
      create_option             = "Empty"
      managed_disk_type         = "Standard_LRS"
      disk_size_gb              = 10
      write_accelerator_enabled = false
      lun                       = disk.key
    }
  }

  storage_image_reference {
    offer     = "WindowsServer"
    publisher = "MicrosoftWindowsServer"
    sku       = "2022-datacenter-smalldisk-g2"
    version   = "latest"
  }

  os_profile_windows_config {
    enable_automatic_upgrades = true
    timezone                  = "GMT Standard Time"
  }

  os_profile {
    computer_name  = lower(module.naming.virtual_machine.name)
    admin_username = "azadmin"
    admin_password = "1QAZ2wsx3edc"
  }
}
