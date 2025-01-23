terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.50"
    }
  }

  backend "azurerm" {
    # Add your backend configuration here if applicable
    # Example:
    # resource_group_name  = "my-backend-rg"
    # storage_account_name = "mystorageaccount"
    # container_name       = "tfstate"
    # key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Virtual Network Module
module "vnet" {
  source              = "./modules/virtual_network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  vnet_name           = var.aks_vnet_name
  address_space       = var.aks_vnet_address_space

  # Define subnets excluding Databricks subnets
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
    }
  ]
}

# Azure Databricks Subnets Module
module "databricks_subnets" {
  source                           = "./modules/azure-databricks-subnets"
  subnet_name_prefix               = var.databricks_subnet_name_prefix
  vnet_resource_group_name         = azurerm_resource_group.rg.name
  vnet_name                        = var.aks_vnet_name  # Changed from module.vnet.vnet_name to var.aks_vnet_name
  private_subnet_address_prefixes  = var.databricks_private_subnet_address_prefix
  public_subnet_address_prefixes   = var.databricks_public_subnet_address_prefixes
  additional_service_endpoints     = var.databricks_additional_service_endpoints
  service_delegation_actions       = var.databricks_service_delegation_actions
  tags                             = var.tags
}




# Azure Databricks Security Groups Module
module "databricks_security_groups" {
  source                      = "./modules/azure-databricks-security-groups"
  security_group_name_prefix  = var.databricks_security_group_name_prefix
  location                    = var.location
  vnet_resource_group_name    = azurerm_resource_group.rg.name

  # Reference subnet IDs from the Databricks Subnets module
  private_subnet_id           = module.databricks_subnets.private_subnet_id
  public_subnet_id            = module.databricks_subnets.public_subnet_id

  tags                        = var.tags
}

# Azure Databricks Workspace Module
module "databricks_workspace" {
  source              = "./modules/azure-databricks-workspace"
  workspace_name      = var.workspace_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  vnet_id             = module.vnet.vnet_id

  # Reference subnet IDs from the Databricks Subnets module
  public_subnet_id    = module.databricks_subnets.public_subnet_id
  private_subnet_id   = module.databricks_subnets.private_subnet_id

  tags                = var.tags
}



# Virtual Machine Module
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

# Key Vault Module
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
  virtual_network_subnet_ids = []
}

# ACR Module
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

# Private Endpoint for Key Vault
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

# Private Endpoint for ACR
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
