terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.50"
    }
  }

  backend "azurerm" {
    # backend configuration details here (if any)
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "vnet" {
  source              = "./modules/virtual_network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  vnet_name           = var.aks_vnet_name
  address_space       = var.aks_vnet_address_space

  # Only include the subnet that will host your virtual machine.
  subnets = [
    {
      name                                         = var.vm_subnet_name
      address_prefixes                             = var.vm_subnet_address_prefix
      private_endpoint_network_policies_enabled    = true
      private_link_service_network_policies_enabled = false
    }
  ]
}

module "virtual_machine" {
  count               = var.vm_count
  source              = "./modules/virtual_machine"
  # Prepend the count index to the base name for uniqueness.
  name                = "${count.index}-${var.vm_name}"
  size                = var.vm_size
  location            = var.location
  public_ip           = var.vm_public_ip
  vm_user             = var.admin_username
  admin_password      = var.admin_password
  os_disk_image       = var.vm_os_disk_image
  domain_name_label   = var.domain_name_label
  resource_group_name = azurerm_resource_group.rg.name

  # Get the subnet ID from the VNet module output.
  subnet_id                   = module.vnet.subnet_ids[var.vm_subnet_name]
  os_disk_storage_account_type = var.vm_os_disk_storage_account_type
}
