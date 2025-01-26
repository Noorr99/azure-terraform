terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.50"
    }
  }
/*
  backend "azurerm" {
    # Backend configuration details here (if any)
  }
*/
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

//
// Virtual Network Module
//
module "vnet" {
  source              = "./modules/virtual_network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  vnet_name           = var.aks_vnet_name
  address_space       = var.aks_vnet_address_space

  subnets = [
    {
      name                                          = var.shared_subnet_name
      address_prefixes                              = var.shared_subnet_address_prefix
      private_endpoint_network_policies_enabled     = false
      private_link_service_network_policies_enabled = true
    }
  ]
}

//
// Data Lake Storage with Private Endpoint and DNS
//
resource "azurerm_storage_account" "datalake_storage_account" {
  name                     = var.datalake_storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.datalake_account_tier
  account_replication_type = var.datalake_account_replication_type
  account_kind             = var.datalake_account_kind
  is_hns_enabled           = var.datalake_is_hns_enabled
  tags                     = var.tags
}

module "datalake_private_dns_zone" {
  source                       = "./modules/private_dns_zone"
  name                         = "privatelink.dfs.core.windows.net"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_networks_to_link     = { (module.vnet.name) = { subscription_id = data.azurerm_client_config.current.subscription_id, resource_group_name = azurerm_resource_group.rg.name } }
  tags                         = var.tags
}

module "datalake_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = "${azurerm_storage_account.datalake_storage_account.name}-pe"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.rg.name
  subnet_id                      = module.vnet.subnet_ids[var.shared_subnet_name]
  private_connection_resource_id = azurerm_storage_account.datalake_storage_account.id
  subresource_name               = "dfs"
  private_dns_zone_group_name    = "DatalakePrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.datalake_private_dns_zone.id]
  tags                           = var.tags
}

//
// Key Vault with Private Endpoint and DNS
//
module "key_vault" {
  source              = "./modules/key_vault"
  name                = var.key_vault_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  tenant_id           = var.tenant_id
  sku_name            = var.key_vault_sku
  tags                = var.tags

  enabled_for_deployment          = var.key_vault_enabled_for_deployment
  enabled_for_disk_encryption     = var.key_vault_enabled_for_disk_encryption
  enabled_for_template_deployment = var.key_vault_enabled_for_template_deployment
  enable_rbac_authorization       = var.key_vault_enable_rbac_authorization
  purge_protection_enabled        = var.key_vault_purge_protection_enabled
  soft_delete_retention_days      = var.key_vault_soft_delete_retention_days
  public_network_access_enabled   = false

  bypass                        = var.key_vault_bypass
  default_action                = var.key_vault_default_action
  ip_rules                      = var.key_vault_ip_rules
  virtual_network_subnet_ids    = []
}

module "keyvault_private_dns_zone" {
  source                       = "./modules/private_dns_zone"
  name                         = "privatelink.vaultcore.azure.net"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_networks_to_link     = { (module.vnet.name) = { subscription_id = data.azurerm_client_config.current.subscription_id, resource_group_name = azurerm_resource_group.rg.name } }
  tags                         = var.tags
}

module "keyvault_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = "${var.key_vault_name}-pe"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.rg.name
  subnet_id                      = module.vnet.subnet_ids[var.shared_subnet_name]
  private_connection_resource_id = module.key_vault.id
  subresource_name               = "vault"
  private_dns_zone_group_name    = "KeyVaultPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.keyvault_private_dns_zone.id]
  tags                           = var.tags
}

//
// SQL Database with Private Endpoint and DNS
//
module "sql_database" {
  source              = "./modules/sql_database"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sql_server_name     = var.sql_server_name
  sql_admin_username  = var.sql_admin_username
  sql_admin_password  = var.sql_admin_password
  sql_database_name   = var.sql_database_name
  sql_database_dtu    = var.sql_database_dtu
  sql_database_tier   = var.sql_database_tier
  sql_database_size_gb = var.sql_database_size_gb
  long_term_retention_backup = var.long_term_retention_backup
  subnet_id           = module.vnet.subnet_ids[var.shared_subnet_name]
  private_dns_zone_id = module.sql_private_dns_zone.id
  tags                = var.tags
}

module "sql_private_dns_zone" {
  source                       = "./modules/private_dns_zone"
  name                         = "privatelink.database.windows.net"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_networks_to_link     = { (module.vnet.name) = { subscription_id = data.azurerm_client_config.current.subscription_id, resource_group_name = azurerm_resource_group.rg.name } }
  tags                         = var.tags
}
