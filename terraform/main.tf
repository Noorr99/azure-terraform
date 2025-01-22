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

//
// Virtual Network Module – expanded to include four subnets:
// - one for VMs, one for private endpoints,
// - one public subnet for Databricks, and one private subnet for Databricks.
//
module "vnet" {
  source              = "./modules/virtual_network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  vnet_name           = var.aks_vnet_name
  address_space       = var.aks_vnet_address_space

  subnets = [
    {
      name                                          = var.vm_subnet_name
      address_prefixes                              = var.vm_subnet_address_prefix
      private_endpoint_network_policies_enabled     = true
      private_link_service_network_policies_enabled = false
    },
    {
      name                                          = var.pe_subnet_name
      address_prefixes                              = var.pe_subnet_address_prefix
      private_endpoint_network_policies_enabled     = false
      private_link_service_network_policies_enabled = true
    },
    {
      name             = var.databricks_public_subnet_name
      address_prefixes = var.databricks_public_subnet_address_prefix
      // Adjust these settings as required for the Databricks public subnet.
      private_endpoint_network_policies_enabled     = false
      private_link_service_network_policies_enabled = false
    },
    {
      name             = var.databricks_private_subnet_name
      address_prefixes = var.databricks_private_subnet_address_prefix
      private_endpoint_network_policies_enabled     = false
      private_link_service_network_policies_enabled = false
    }
  ]
}

//
// Virtual Machine Module (unchanged)
//
module "virtual_machine" {
  count               = var.vm_count
  source              = "./modules/virtual_machine"

  name                = "${count.index}-${var.vm_name}"
  size                = var.vm_size
  location            = var.location
  public_ip           = var.vm_public_ip
  vm_user             = var.admin_username
  admin_password      = var.admin_password
  os_disk_image       = var.vm_os_disk_image
  domain_name_label   = var.domain_name_label
  resource_group_name = azurerm_resource_group.rg.name

  subnet_id                   = module.vnet.subnet_ids[var.vm_subnet_name]
  os_disk_storage_account_type = var.vm_os_disk_storage_account_type
}

//
// Key Vault Module Deployment
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

  bypass                     = var.key_vault_bypass
  default_action             = var.key_vault_default_action
  ip_rules                   = var.key_vault_ip_rules
  // With private endpoints in use, leave virtual_network_subnet_ids empty.
  virtual_network_subnet_ids = []
}

//
// ACR Module Deployment (using the container_registry module)
//
module "acr" {
  source              = "./modules/container_registry"
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  admin_enabled       = var.acr_admin_enabled
  sku                 = var.acr_sku
  tags                = var.tags

  georeplication_locations = var.acr_georeplication_locations
}

//
// Private Endpoint for Key Vault
//
resource "azurerm_private_endpoint" "key_vault_pe" {
  name                = "${var.key_vault_name}-pe"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  subnet_id = module.vnet.subnet_ids[var.pe_subnet_name]

  private_service_connection {
    name                           = "${var.key_vault_name}-psc"
    private_connection_resource_id = module.key_vault.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }
}

//
// Private Endpoint for ACR
//
resource "azurerm_private_endpoint" "acr_pe" {
  name                = "${var.acr_name}-pe"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  subnet_id = module.vnet.subnet_ids[var.pe_subnet_name]

  private_service_connection {
    name                           = "${var.acr_name}-psc"
    private_connection_resource_id = module.acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }
}

//
// Databricks Module Deployment
//

module "databricks" {
  source               = "./modules/databricks"
  name                 = var.databricks_workspace_name
  resource_group_name  = azurerm_resource_group.rg.name
  location             = var.location
  sku                  = var.databricks_workspace_sku
  virtual_network_id   = module.vnet.vnet_id
  virtual_network_name = module.vnet.name
  public_subnet_name   = var.databricks_public_subnet_name
  private_subnet_name  = var.databricks_private_subnet_name
  tags                 = var.tags
}
