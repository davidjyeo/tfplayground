packer {
  required_plugins {
    windows-update = {
      version = "~>0.14.3"
      source  = "github.com/rgl/windows-update"
    }
    azure = {
      version = "~>1.0"
      source  = "github.com/hashicorp/azure"
    }
  }
}

variable "rg" {
  type    = string
  default = "AZDEV-YEOD-AT-AZLLOYDSDEV-DOT-COM"
}

variable "publisher" {
  type    = string
  default = "MicrosoftWindowsServer"
}

variable "offer" {
  type    = string
  default = "WindowsServer"
}

variable "sku" {
  type    = string
  default = "2019-datacenter-densecond"
}

source "azure-arm" "w2k19" {
  build_resource_group_name = var.rg
  managed_image_resource_group_name = var.rg
  communicator              = "winrm"
  image_offer               = var.offer
  image_publisher           = var.publisher
  image_sku                 = var.sku
  managed_image_name        = "AZDEV-YEOD-001"
  os_type                   = "Windows"
  vm_size                   = "Standard_d4_v5"
  winrm_insecure            = true
  winrm_timeout             = "1h"
  winrm_use_ssl             = true
  winrm_username            = "pkradmn"
  subscription_id           = "19067dda-d761-44a6-b79d-29a8e342f633"
}

build {
  sources = ["source.azure-arm.w2k19"]

  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "include:$true",
    ]
  }
}
