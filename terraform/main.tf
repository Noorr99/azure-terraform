########################################
# Terraform & Provider Config
########################################
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.50"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

########################################
# Data
########################################
data "azurerm_client_config" "current" {}

########################################
# Locals
########################################
locals {
  storage_account_prefix = "boot"
}

########################################
# Resource Group
########################################
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

########################################
# VNet & Only Needed Subnet
########################################
module "aks_network" {
  source              = "./modules/virtual_network"
  resource_group_name = azurerm_resource_group.rg.name
  location           = var.location
  vnet_name          = var.aks_vnet_name
  address_space      = var.aks_vnet_address_space

  subnets = [
    {
      name                                         = var.vm_subnet_name
      address_prefixes                             = var.vm_subnet_address_prefix
      private_endpoint_network_policies_enabled    = true
      private_link_service_network_policies_enabled = false
    }
  ]
}

########################################
# Random String (for Storage Account Name)
########################################
resource "random_string" "storage_account_suffix" {
  length  = 8
  special = false
  lower   = true
  upper   = false
  numeric = false
}

########################################
# Storage Account (for VM Boot Diagnostics)
########################################
module "storage_account" {
  source              = "./modules/storage_account"
  name                = "${local.storage_account_prefix}${random_string.storage_account_suffix.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  account_kind        = var.storage_account_kind
  account_tier        = var.storage_account_tier
  replication_type    = var.storage_account_replication_type
}

########################################
# Container Registry (ACR)
########################################
module "container_registry" {
  source                   = "./modules/container_registry"
  name                     = var.acr_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  sku                      = var.acr_sku
  admin_enabled            = var.acr_admin_enabled
  georeplication_locations = var.acr_georeplication_locations
}

########################################
# Key Vault
########################################
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
  enable_rbac_authorization       = var.key_vault_enable_rbac_authorization
  purge_protection_enabled        = var.key_vault_purge_protection_enabled
  soft_delete_retention_days      = var.key_vault_soft_delete_retention_days
  bypass                          = var.key_vault_bypass
  default_action                  = var.key_vault_default_action
}

########################################
# Virtual Machine
########################################
module "virtual_machine" {
  source                           = "./modules/virtual_machine"
  name                             = var.vm_name
  size                             = var.vm_size
  location                         = var.location
  public_ip                        = var.vm_public_ip
  vm_user                          = var.admin_username
  admin_ssh_public_key             = var.ssh_public_key
  os_disk_image                    = var.vm_os_disk_image
  domain_name_label                = var.domain_name_label
  resource_group_name              = azurerm_resource_group.rg.name
  subnet_id                        = module.aks_network.subnet_ids[var.vm_subnet_name]
  os_disk_storage_account_type     = var.vm_os_disk_storage_account_type
  boot_diagnostics_storage_account = module.storage_account.primary_blob_endpoint

  # Remove log analytics references if not needed.
  # Remove script_* if not used for initialization scripts:
  # script_storage_account_name  = var.script_storage_account_name
  # script_storage_account_key   = var.script_storage_account_key
  # container_name               = var.container_name
  # script_name                  = var.script_name
}

########################################
# Private DNS Zones (ACR, Blob, Key Vault)
########################################
module "acr_private_dns_zone" {
  source              = "./modules/private_dns_zone"
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.rg.name

  virtual_networks_to_link = {
    (module.aks_network.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.rg.name
    }
  }
}

module "blob_private_dns_zone" {
  source              = "./modules/private_dns_zone"
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name

  virtual_networks_to_link = {
    (module.aks_network.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.rg.name
    }
  }
}

module "key_vault_private_dns_zone" {
  source              = "./modules/private_dns_zone"
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg.name

  virtual_networks_to_link = {
    (module.aks_network.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.rg.name
    }
  }
}

########################################
# Private Endpoints
########################################
module "acr_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = "${module.container_registry.name}PrivateEndpoint"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.rg.name
  subnet_id                      = module.aks_network.subnet_ids[var.vm_subnet_name]
  tags                           = var.tags
  private_connection_resource_id = module.container_registry.id
  is_manual_connection           = false
  subresource_name               = "registry"
  private_dns_zone_group_name    = "AcrPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.acr_private_dns_zone.id]
}

module "blob_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = "${title(module.storage_account.name)}PrivateEndpoint"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.rg.name
  subnet_id                      = module.aks_network.subnet_ids[var.vm_subnet_name]
  tags                           = var.tags
  private_connection_resource_id = module.storage_account.id
  is_manual_connection           = false
  subresource_name               = "blob"
  private_dns_zone_group_name    = "BlobPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.blob_private_dns_zone.id]
}

module "key_vault_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = "${title(module.key_vault.name)}PrivateEndpoint"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.rg.name
  subnet_id                      = module.aks_network.subnet_ids[var.vm_subnet_name]
  tags                           = var.tags
  private_connection_resource_id = module.key_vault.id
  is_manual_connection           = false
  subresource_name               = "vault"
  private_dns_zone_group_name    = "KeyVaultPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.key_vault_private_dns_zone.id]
}
