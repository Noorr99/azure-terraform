terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.50"
    }
  }
}

provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Virtual Network
module "vnet" {
  source              = "./modules/virtual_network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  vnet_name           = var.vnet_name
  address_space       = var.vnet_address_space
  tags                = var.tags

  subnets = [
    {
      name                                      = var.vm_subnet_name
      address_prefixes                          = var.vm_subnet_address_prefix
      private_endpoint_network_policies_enabled = true
      private_link_service_network_policies_enabled = false
    },
    {
      name                                      = "AzureBastionSubnet"
      address_prefixes                          = var.bastion_subnet_address_prefix
      private_endpoint_network_policies_enabled = true
      private_link_service_network_policies_enabled = false
    }
  ]
}

# Azure Container Registry
module "acr" {
  source                       = "./modules/container_registry"
  name                         = var.acr_name
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = var.location
  sku                          = var.acr_sku
  admin_enabled                = var.acr_admin_enabled
}

# Storage Account
module "storage_account" {
  source              = "./modules/storage_account"
  name                = var.storage_account_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  account_kind        = var.storage_account_kind
  account_tier        = var.storage_account_tier
  replication_type    = var.storage_account_replication_type
}

# Key Vault
module "key_vault" {
  source                          = "./modules/key_vault"
  name                            = var.key_vault_name
  location                        = var.location
  resource_group_name             = azurerm_resource_group.rg.name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = var.key_vault_sku_name
  tags                            = var.tags
  enabled_for_deployment          = var.key_vault_enabled_for_deployment
  enabled_for_disk_encryption     = var.key_vault_enabled_for_disk_encryption
  enabled_for_template_deployment = var.key_vault_enabled_for_template_deployment
}

# Bastion Host
module "bastion" {
  source              = "./modules/bastion_host"
  name                = var.bastion_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = module.vnet.subnet_ids["AzureBastionSubnet"]
}

# Virtual Machine
module "vm" {
  source                      = "./modules/virtual_machine"
  name                        = var.vm_name
  size                        = var.vm_size
  location                    = var.location
  resource_group_name         = azurerm_resource_group.rg.name
  subnet_id                   = module.vnet.subnet_ids[var.vm_subnet_name]
  admin_username              = var.admin_username
  admin_ssh_public_key        = var.ssh_public_key
  os_disk_storage_account_type = var.vm_os_disk_storage_account_type
}

# Private DNS Zone for ACR
module "acr_private_dns_zone" {
  source                  = "./modules/private_dns_zone"
  name                    = "privatelink.azurecr.io"
  resource_group_name     = azurerm_resource_group.rg.name
  virtual_networks_to_link = {
    module_vnet = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.rg.name
    }
  }
}

# Private Endpoint for ACR
module "acr_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = "${module.acr.name}PrivateEndpoint"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.rg.name
  subnet_id                      = module.vnet.subnet_ids[var.vm_subnet_name]
  private_connection_resource_id = module.acr.id
  private_dns_zone_group_ids     = [module.acr_private_dns_zone.id]
}

# Private DNS Zone for Storage
module "storage_private_dns_zone" {
  source                  = "./modules/private_dns_zone"
  name                    = "privatelink.blob.core.windows.net"
  resource_group_name     = azurerm_resource_group.rg.name
  virtual_networks_to_link = {
    module_vnet = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.rg.name
    }
  }
}

# Private Endpoint for Storage
module "storage_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = "${module.storage_account.name}PrivateEndpoint"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.rg.name
  subnet_id                      = module.vnet.subnet_ids[var.vm_subnet_name]
  private_connection_resource_id = module.storage_account.id
  private_dns_zone_group_ids     = [module.storage_private_dns_zone.id]
}

# Private DNS Zone for Key Vault
module "key_vault_private_dns_zone" {
  source                  = "./modules/private_dns_zone"
  name                    = "privatelink.vaultcore.azure.net"
  resource_group_name     = azurerm_resource_group.rg.name
  virtual_networks_to_link = {
    module_vnet = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.rg.name
    }
  }
}

# Private Endpoint for Key Vault
module "key_vault_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = "${module.key_vault.name}PrivateEndpoint"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.rg.name
  subnet_id                      = module.vnet.subnet_ids[var.vm_subnet_name]
  private_connection_resource_id = module.key_vault.id
  private_dns_zone_group_ids     = [module.key_vault_private_dns_zone.id]
}
